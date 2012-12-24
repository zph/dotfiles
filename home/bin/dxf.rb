# dxf2ruby.rb - (C) 2011 jim.foltz@gmail.com
# $Id$

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# == Purpose ==
#
# To parse .dxf files into something useful by Ruby using only built-in Ruby
# objects (Hash, Array, Float, Fixnum, String). Meant to be a building-block
# for more advanced DXF processing.


# == Quick Start ==
#
#   require 'dxf2ruby'
#   dxf = Dxf2Ruby.parse("file.dxf")
#   acad_version =  dxf['HEADER']['$ACADVER']
#   dxf['ENTITIES'].each do |entity|
#      draw(entity)
#   end
#
#   def draw(entity)
#       case entity[0]
#         when "POINT"
#           draw_point(entity)
#        when "LINE"
#           draw_line(entity)
#      end
#   end
#
# Dxf2RUby may also be used on a command line:
#
#       $ dxf2ruby file.dxf

# == About ==
#
# dxf2ruby returns a Ruby data structure from a .dxf file. Dxf2Ruby does not
# attempt to interpret the codes, but rather assembles the codes into Acad
# objects in the form of Ruby Hashes.
#
# The top-level data structure is a Hash of containers representing SECTIONS of
# the .dxf file.  Currently supported sections are the HEADER, BLOCKS, and
# ENTITIES sections.
#
#   {"HEADER"=>{...}, "BLOCKS"=>[...], "ENTITIES"=>[...]}


# == The HEADER Section ==
#
#    The HEADER section is a Ruby Hash object. Reading the HEADER variables can
#    be done as follows:
#
#       header = dxf['HEADER']
#       acad_version = header['$ACADVER'][1]
#
#    Non-existant variable return nil.


# == The BLOCKS Section ==
#
# The BLOCKS section is a Ruby Array.


# == The ENTITIES Section ==
#
# Acad entities are returned as Ruby Hashes.  A typical entity may look similar
# to the following Hash, which represents an Acad LINE entity:
#
#   {0=>"LINE", 5=>"25", 100=>["AcDbEntity", "AcDbLine"], 8=>"0",
#   6=>"CONTINUOUS", 62=>7, 10=>-4.672884, 20=>-0.816414, 30=>0.0,
#   11=>-4.672884, 21=>-0.27178, 31=>0.0}


# About DXF (Nots from AutoCAD)
#
# DXF _Objects_ have no graphical representation. (aka nongraphical objects)
# DXF _Entities_ are graphical objects.

# Accommodating DXF files from future releases of AutoCAD® will be easier
# if you write your DXF processing program in a table-driven way, ignore
# undefined group codes, and make no assumptions about the order of group codes
# in an entity. With each new AutoCAD release, new group codes will be added to
# entities to accommodate additional features.

module Dxf

    #
    # A Dxf "Entity" is a Graphical Object
    #
    class Entity

        def initialize(entity_type = "UNKNOWN")
            @codes = {0=>entity_type}
        end
        def code(x)
            @codes[x]
        end
        def update(c, v)
            if @codes[c].nil?
                @codes[c] = v
            elsif @codes[c].class == Array
                @codes[c] << v
            else
                t = @codes[c]
                @codes[c] = []
                @codes[c] << t
                @codes[c] << v
            end
        end
        
        # Codes that apply to all graphical objects (Entities)
        def handle
            @codes[5]
        end
        def layer_name
            @codes[8]
        end
        def paper_space?
            @codes.fetch(67, 0) == 1
        end
        def model_space?
            not paper_space?
        end
    end # class Entity

    class Vertex < Entity
        #attr_reader :location
        def initialize(entity_type = "VERTEX")
            super
        end
        def location
            [ @codes[10], @codes[20], @codes.fetch(30, 0.0) ]
        end
        def bulge
            @codes.fetch(42, 0.0)
        end
        def flags
            # 1   = Extra vertex created by curve-fitting
            # 2   = Curve-fit tangent defined for this vertex. A curve-fit tangent direction of 0 may be omitted
            #       from DXF output but is significant if this bit is set
            # 4   = Not used
            # 8   = Spline vertex created by spline-fitting
            # 16  = Spline frame control point
            # 32  = 3D polyline vertex
            # 64  = 3D polygon mesh
            # 128 = Polyface mesh vertex
            @codes[70]
        end
    end

    class Line < Entity
        def initialize(entity_type = "LINE")
            super
        end
        def start_point
            [ @codes[10], @codes[20], @codes.fetch(30, 0.0) ]
        end
        def end_point
            [ @codes[11], @codes[21], @codes.fetch(31, 0.0) ]
        end
        def thickness
            @codes.fetch(39, 0.0)
        end
        def extrusion_direction
            [ @codes.fetch(210, 0.0), @codes.fetch(220, 0.0), @code.fetch(230, 1.0) ]
        end
    end

    class Polyline < Entity
        attr_reader :vertices
        def initialize(type = "POLYLINE")
            @vertices = []
            super
        end
        def add_vertex(v)
            @vertices << v
        end
    end

    class Circle < Entity
        def initialize(t="CIRCLE")
            super
        end
    end

    class Entities
        def initialize
            @list = []
            @verts = []
            @polyline = nil
            @last_entity = nil
        end

        def create_entity(type)
            case type
            #when "ENDSEC"
            #    @last_entity = nil
            when "LINE"
                @last_entity = Line.new
                @list.push(@last_entity)
            when "CIRCLE"
                @last_entity = Circle.new
                @list.push(@last_entity)
            when "POLYLINE"
                @polyline = Polyline.new
                @last_entity = @polyline
                @list.push(@last_entity)
            when "VERTEX"
                vertex = Vertex.new
                @polyline.add_vertex(vertex) if @polyline
                @last_entity = vertex
            when "SEQEND"
                @polyline = nil if @polyline
            else
                # Create a generic Entity
                @last_entity = Entity.new(type)
                # Skip it for now
                #@list.push(@last_entity)
            end
        end

        def last_entity
            @last_entity
        end

        #def update(hsh)
        #    if hsh[0] == "POLYLINE"
        #        @verts.clear
        #        @polyline = hsh
        #    elsif hsh[0] == "VERTEX" and @polyline
        #        @verts.push(Vertex.new(hsh))
        #    elsif hsh[0] == "SEQEND" and @polyline
        #        @polyline['VERTICES'] = @verts.clone
        #        @verts.clear
        #        @list.push(@polyline)
        #        @polyline = nil
        #    else
        #        @list.push(hsh)
        #    end
        #end

        def each
            return unless block_given?
            @list.each { |entity| yield(entity) }
        end

    end # class Entities
end

module Dxf2Ruby

    module_function

    def parse(filename)
        @debug = $JFDEBUG
        fp = File.open(filename)

        dxf = {
            'HEADER' => {},
            'BLOCKS' => [],
            'ENTITIES' => Dxf::Entities.new
        }
        last_code = nil
        last_ent  = nil

        #
        # main loop
        #

        c = v = nil
        while v != "EOF"
            c, v = read_codes(fp)
            if v == "SECTION"
                c, v = read_codes(fp)

                if v == "HEADER"
                    hdr = dxf['HEADER']
                    while true
                        c, v = read_codes(fp)
                        break if v == "ENDSEC"
                        if c == 9
                            key = v
                            hdr[key] = {}
                        else
                            add_att(hdr[key], c, v)
                        end
                    end # while
                end # if HEADER

                #    if v == "BLOCKS"
                #        blks = dxf[v]
                #        while true
                #            c, v = read_codes(fp)
                #            break if v == "ENDSEC"
                #            next if c == 999
                #            if last_ent == "LWPOLYLINE"
                #                if last_code == 20 and c != 42
                #                    add_att(blks[-1], 42, 0.0)
                #                end
                #            end
                #            if c == 0
                #                last_ent = v
                #                blks << {c => v}
                #            else
                #                add_att blks[-1], c, v
                #            end
                #            last_code = c
                #        end # while
                #    end # if BLOCKS


                if v == "ENTITIES"
                    entities = dxf[v]
                    c, v = read_codes(fp)
                    while v != "ENDSEC"
                        if c == 0
                            entities.create_entity(v)
                        else
                            entities.last_entity.update(c, v)
                        end
                        c, v = read_codes(fp)
                    end
                end

            end # if in SECTION

        end # main loop

        return dxf
    end

    def read_codes(fp)
        c = fp.gets.to_i
        v = fp.gets.strip
        v.upcase! if c == 0
        case c
        when 10..59, 140..147, 210..239, 1010..1059
            v = v.to_f
        when 60..79, 90..99, 170..175,280..289, 370..379, 380..389,500..409, 1060..1079
            v = v.to_i
        end
        codes = [c, v]
        return(codes)
    end

    def add_att(ent, code, value)
        if ent.nil? and @debug
            p caller
            p code
            p value
        end
        if ent[code].nil?
            ent[code] = value
        elsif ent[code].class == Array
            ent[code] << value
        else
            t = ent[code]
            ent[code] = []
            ent[code] << t
            ent[code] << value
        end
    end


end # class Dxf2Ruby


if $0 == __FILE__
    require 'pp'
    t1 = Time.now
    dxf = Dxf2Ruby.parse(ARGV.shift)
    puts "Finsihed in #{Time.now - t1}"
    #dxf['ENTITIES'].each { |e|
    #    pp e
    #    puts
    #}
    pp dxf
end
