#!/bin/bash
#
# note 1: Soot or one of its module has a hard time dealing with Java files
# generated byt this script.
# A solution is to compile Java source code to bytecode and make Soot
# analyze the bytecode.
# Go to the directory where the source code has been generated and type:
# javac -cp .:../api/android.jar -d ./classes/ *.java
#
# note 2: it seems that Soot optimize the code when transforming the bytecode
# to Jimple. Thus, if the bytecode generated from Wrappers in which objects are
# not initialized is analyzed by Soot, it may be the case that method calls
# on null objects are missing.
# solution: generate wrappers without '-d' option
#
# note 3: error such as "soot.RefType cannot be cast to soot.ArrayType for a given
# method of a given class. Solution: convert this class in Jimple with Soot, then
# replace .class file by equivalent in Jimple (beware that the Jimple file must be
# located as the root of Java package).
# Soot throws this exception when analyzing class com.android.server.sip.SipService
# of Android 4.0.1_r1.
#
# note 4: check that there are no other paths to other entry point wrappers when running
# findpermbissionscheck script


function usage {
cat << EOF
Usage: $0 -e <path> -o <path> -s <path-to-soot-classes>

OPTIONS:
   -h      Show this message
   -t      Path to directory containing the target library (can be a jar file).
           Example: Android API.
   -b      Path to directory containing the Android system bytecode. This 
           option is useful only if the bytecode has been modified to redirect
           system services, ie ServicesInit.class and managers.txt do exist)
   -c      Path to configuration file.
   -d      Disable type generation.
   -o      Output directory.
   -s      Path to Soot classes (.jar or directory)
   -v      Verbose.
EOF
  exit -1
}

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
	# error; for some reason, the path is not accessible
	# to the script (e.g. permissions re-evaled after suid)
	exit 1  # fail
fi
cd $MY_PATH

# parse arguments
TARGET_LIBRARY_PATH=""
SYSTEM_BYTECODE_PATH=""
CONFIG_FILE=""
SOOT_OUT_DIR=""
SOOT_CLASSES=""
GENERATE_TYPES="true"
VERBOSE="false"
while getopts “ht:b:c:o:s:dv” OPTION
do
    case $OPTION in
         h)
             usage
             exit 1
             ;;
         t)
             TARGET_LIBRARY_PATH=$OPTARG
             ;;
         b)
             SYSTEM_BYTECODE_PATH=$OPTARG
             ;;
         c)
             CONFIG_FILE=$OPTARG
             ;;
         o)
             SOOT_OUT_DIR=$OPTARG
             ;;
         s)
             SOOT_CLASSES=$OPTARG
             ;;
         d)
             GENERATE_TYPES="false"
             ;;
         v)
             VERBOSE="true"
             ;;
         ?)
             usage
             exit
             ;;
    esac
done

if [ -z $TARGET_LIBRARY_PATH ] ; then
  echo "error: target library not specified."
  usage
  exit -1
fi
if [ -z $SOOT_OUT_DIR ] ; then
  echo "error: output directory not specified."
  usage
  exit -1
fi
if [[ ! $SOOT_OUT_DIR =~ .*/ ]]
then
  SOOT_OUT_DIR=$SOOT_OUT_DIR"/"
fi
if [ -z $CONFIG_FILE ] ; then
  CONFIG_FILE="${TARGET_LIBRARY_PATH}/config.cfg"
fi
if [ ! -f $CONFIG_FILE ] ; then
  echo "error: config file does not exist (${CONFIG_FILE})."
  usage
  exit -1
fi
#if [ -z $SYSTEM_BYTECODE_PATH ] ; then
#  SYSTEM_BYTECODE_PATH="none"
#else
#  SINIT_DIR="/tmp/servicesinit/"
#  mkdir $SINIT_DIR
#  cp "$SYSTEM_BYTECODE_PATH/ServicesInit.class" "$SINIT_DIR" 
#  SOOT_CLASSPATH=$SOOT_CLASSPATH:$SINIT_DIR
#  PROCESS_THIS="$PROCESS_THIS -process-dir ${SINIT_DIR} "
#fi
#if [ "$SOOT_CLASSES" == "" ] ; then
#  echo "error: no path to soot classes specified!"
#  usage
#  exit -1
#fi
#
## classes to process
##PROCESS_THIS="$PROCESS_THIS -process-dir ${TARGET_LIBRARY_PATH} "

PROCESS_THIS=" -process-dir ${SYSTEM_BYTECODE_PATH}/systeminit.code/ "
PROCESS_THIS="$PROCESS_THIS -process-dir ${SYSTEM_BYTECODE_PATH}/android.code/ "

SOOT_JAR=${SOOT_CLASSES}

JAVA_CLASSPATH="\
$MY_PATH/../bin/:\
$SOOT_JAR:\
"

SOOT_CLASSPATH=$SOOT_CLASSPATH":\
"

SOOT_CMD="lu.uni.epw.GenerateLibraryWrappers \
  -config $CONFIG_FILE \
  -manager $SYSTEM_BYTECODE_PATH/android.code/ \
  -manager-classes $TARGET_LIBRARY_PATH \
  -generateTypes $GENERATE_TYPES \
  --soot-classpath $SOOT_CLASSPATH\
  -d $SOOT_OUT_DIR \
	-f n \
 -allow-phantom-refs \
 $PROCESS_THIS
"

if [[ $VERBOSE == "true" ]] ; then
  SOOT_CMO=$SOOT_CMD" -v "
fi

echo "java classpath: "$JAVA_CLASSPATH
echo "soot command  : "$SOOT_CMD

# start soot
java -Xmx2000m -classpath \
${JAVA_CLASSPATH} \
${SOOT_CMD}\

