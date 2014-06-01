#!/bin/sh

#set -vx 

#####
# converts tab-separated data to a sqlite db
# tries to "do the right thing" when given partial commands
# note - does strip most punctuation from column names
#
# version 1.0 8/15/2008
# by t2sql@jobbogan.com copyright 2008 
#
# released under the Artistic License v2.0 - see these URLs for full license terms
# http://www.opensource.org/licenses/artistic-license-2.0.php
# http://www.perlfoundation.org/artistic_license_2_0
#####

#####
# BUGS:
#  should check for matching number of fields when we're appending
#  has issues w/ delims other than whitespace (near line 124 - $countfoo stuff)
#  should allow for multi char delims
#   i think awk is the only problem here
#  should trap exit codes and cleanup files, but i'm lazy and they help debug
#####

PROGNAME=t2sql

export DELIM="	" # default delim to tab

HTMP=`mktemp`
HLINE=`mktemp`
SQLTEXT=`mktemp`
CLEANUP="${CLEANUP} ${HTMP} ${HLINE} ${SQLTEXT}"

#####
# First, we get our options sorted out...
TEMP=`getopt -o i:o:t:d:nH:ah \
	--long input:,output:,table:,delimiter:,header:,noheader,append,help \
	-n ${PROGNAME} -- \
	"$@"`
# if we errored on getopt, exit...
if [ $? != 0 ] ; then echo "error in options" >&2 ; exit 1 ; fi
eval set -- "$TEMP"
while true ; do
        case "$1" in
	    -i|--input) INPUT=${2} ; shift 2 ;;
	    -o|--output) OUTPUT=${2} ; shift 2 ;;
	    -t|--table) TABLE=${2} ; shift 2 ;;
	    -d|--delimiter) DELIM=${2} ; shift 2 ;;
	    -n|--noheader) NOHEADER=1 ; shift ;;
	    -H|--header) HEADER=${2} ; shift 2 ;;
	    -a|--append) APPEND=1 ; shift ;;
	    -h|--help) 
		echo "Usage: ${PROGNAME} [options]"
		echo " -i|--input		source of input data"
		echo " -o|--output		data output location"
		echo " -t|--table		what table name to insert the data into"
		echo " -d|--delimiter		delimiter character separating fields"
		echo " -n|--noheader		there is no header line -> make up column names if new table"
		echo " -H|--header		use this as the header/column names"
		echo " -a|--append		append data to existing table (do not drop table)"
		echo ""
		echo " -h|--help		this help information"
		exit 0
		;;
	    --) shift ; break ;;
	    *) echo "${PROGNAME}: option handling error!" ; exit 1 ;;
        esac
done
#####

#####
# Do some processing of those options
if [ -n "${HEADER}" -a -n "${NOHEADER}" ] ; then
    echo "error - header conflicts: noheader & header supplied" >&2
    exit 1
fi

if [ -z "${INPUT}" -o "${INPUT}" == "-" ]; then
    # store stdin in a file... makes life easier  and add to delete list
    INPUT=`mktemp`
    CLEANUP="${CLEANUP} ${INPUT}"
    cat > ${INPUT}
fi

if [ ! -r "${INPUT}" ] ; then
    echo "error - input file unreadable or does not exist." >&2
    exit 1
fi

TEMP=`cat ${INPUT} | awk -F "$DELIM" '{print NF}' | sort | uniq | wc -l`
if [ "${TEMP}" -ne 1 ] ; then
    echo "error: inconsistent number of fields in input" >&2 ; exit 1
fi
NUMFIELDS=`cat ${INPUT} | awk -F "$DELIM" '{print NF}' | head -1`

if [ -z "${OUTPUT}" ]; then
    OUTPUT=`mktemp`
    echo OUTPUT: ${OUTPUT}
fi
if [ -z "${TABLE}" ]; then
    TABLE="table_${$}"
    echo TABLE: ${TABLE}
fi

if [ "${NOHEADER}" == 1 ];  then
    HEADER=`seq -s"${DELIM}field" ${NUMFIELDS}`
    HEADER="field${HEADER}"
    INPUTNOHEAHDER="${INPUT}"
else 
    if [ -n "${HEADER}" ]; then
	INPUTNOHEAHDER="${INPUT}"
    else
	HEADER=`head -1 "${INPUT}"`
	# Pull off the header line
	INPUTNOHEAHDER=`mktemp`
	CLEANUP="${CLEANUP} ${INPUTNOHEAHDER}"
	cat "${INPUT}" | sed 1d > ${INPUTNOHEAHDER}
    fi
fi

#####


#####
# Let's make the table definition

# clean the headers of excess leading/trailing whitespace
# and "fix" empty fields
# also, pull all punctuation & convert them to double underscore
# there might be a bug here... if you have pathological col names.

echo "${HEADER}" | \
    tr "${DELIM}" \\n | \
    sed 's/^ *$//g' | \
    sed 's/ *$//g' | \
    tr -c \\n[:alnum:] _ | \
    sed 's/_/__/g' | \
    sed 's/^$/empty/g' > ${HTMP}

cat ${HTMP} | while read L
do
#  eval COUNT='${'`echo count${L}`'}'
#  CUR="count${L}"
#  eval COUNT=\"'${'${CUR}'}'\"
  eval COUNT='${'`echo count${L}`'}'

  # add numbers to duplicate field names
  if [ -z "${COUNT}" ]; then
      echo -n " \"${L}\"," >> ${HLINE}
  else 
      echo -n " \"${L}_${COUNT}\"," >> ${HLINE}
  fi

  # fix up the counters for the next round
  if [ -z "${COUNT}" ] ; then
      COUNT=0
  fi
  COUNT=`expr "${COUNT}" + 1`
  eval count${L}="${COUNT}"
  unset COUNT
done

COLS=`cat ${HLINE} | sed s/,$//g` # clean off the trailing , so it's SQL correct
#####


#####
# build the SQL commands
TEXIST=`echo .schema | sqlite3 ${OUTPUT} | grep "CREATE TABLE" | sed 's/^CREATE TABLE //g' | cut -d' ' -f1 | grep ${TABLE}`
if [ "${TEXIST}" == "${TABLE}" ] ; then
    TEXIST=1
else
    TEXIST=0
fi

if [ "${APPEND}" == "1" ] ; then
    # in append mode... if the table does not exist, make it
    if [ "${TEXIST}" == "0" ] ; then
	echo "create table ${TABLE} ( ${COLS} ) ;" >> ${SQLTEXT}
    fi
else
    # if we're in overwrite mode, check if the table exists & drop if it does
    if [ "${TEXIST}" == "1" ] ; then
	echo "drop table ${TABLE};" >> ${SQLTEXT}
    fi
    echo "create table ${TABLE} ( ${COLS} ) ;" >> ${SQLTEXT}
fi
echo ".separator '${DELIM}'"  >> ${SQLTEXT}
echo ".import ${INPUTNOHEAHDER} ${TABLE}"  >> ${SQLTEXT}

#cat ${SQLTEXT}

#####
# Finally, do the work
sqlite3 ${OUTPUT} <${SQLTEXT}
#####

#####
# end & clean up
rm -rf ${CLEANUP}
#####
