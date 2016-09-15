#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# pcscf generate config script

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options_pcscf" ]; then
	source $SCRIPTS_PATH/default_options_pcscf
fi 

if [ -z "$SCRIPTS_PATH" ]; then
	echo "$SERVICE : Using default script path $SCRIPTS_PATH"
	SCRIPTS_PATH="/opt/openbaton/scripts"
else
	echo "$SERVICE : Using custom script path $SCRIPTS_PATH"
fi

VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

# Check for variables
if [ -z "$port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : port not defined, will use default : 4060"
	port="4060"
fi

if [ -z "$name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : name not defined, will use default : pcscf"
	name="pcscf"
fi

if [ -z "$mgmt" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is not mgmt network!"
	exit 1
fi


# Also load variables from the relations

if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
fi

if [ -z "$realm" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no realm for bind9!"
	exit 1
fi


# Prepare a variable containing the hostname used in the bind9 nameserver

bind9_entry=$name.$realm

# Prepare a variable containing the bind9 realm with outslashed points
slashed_rea=$(echo $realm | sed s/\\./\\\\./g)

# Copy our template to the correct location

cp $CFG_INPUT_FILE $CFG_OUTPUT_FILE

# Fill the template

python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_DIAMETER_LISTEN%$mgmt
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_PCSCF_PORT%$port
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_DNS_ENTRY%$bind9_entry
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_DNS_REALM%$realm
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_DNS_REA_SLASHED%$slashed_rea
