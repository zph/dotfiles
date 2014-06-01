#!/usr/bin/env ruby
# Credit for Js calculations: http://thirdculture.com/joel/shumi/computer/hardware/ppicalc.html
# #!/usr/bin/env node
#
# function ppiCalc(form){
#   var horizontal = getEnv(HORIZONTAL);
#   var vertical   = getEnv(VERTICAL);
#   var diagonal   = getEnv(DIAGONAL);
#   var ppi=form.ppi.value;
#   var dotmm=form.dotmm.value;
#   {ppi=(Math.sqrt((horizontal*horizontal)+(vertical*vertical)))/diagonal;
#     form.ppi.value=Math.round((ppi)*100)/100;
#     dotmm=(horizontal/((Math.sqrt((horizontal*horizontal)+(vertical*vertical)))/(diagonal*25.4)))/horizontal;
#     form.dotmm.value=Math.round((dotmm)*10000)/10000;
#   }
# }

horiz, vert, diagonal = ARGV[ 0..2 ].map(&:to_i)

ppi = (Math.sqrt((horiz * horiz)+(vert * vert))) / diagonal

puts "PPI #{ppi}"
