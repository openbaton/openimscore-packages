#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# icscf scscf relation joined script

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options" ]; then
	source $SCRIPTS_PATH/default_options
fi 

if [ -z "$SCRIPTS_PATH" ]; then
	echo "$SERVICE : Using default script path $SCRIPTS_PATH"
	SCRIPTS_PATH="/opt/openbaton/scripts"
else
	echo "$SERVICE : Using custom script path $SCRIPTS_PATH"
fi

VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

# Check for icscf related information

if [ -z "$scscf_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no scscf_name! Using default : scscf"
	scscf_name="scscf"
fi

if [ -z "$scscf_port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no scscf_port! Using default : 6060"
	scscf_port="6060"
fi

# Save variables related to icscf into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "scscf_name=%s\n" \"$scscf_name\" >> $VARIABLE_BUCKET
printf "scscf_port=%s\n" \"$scscf_port\" >> $VARIABLE_BUCKET
