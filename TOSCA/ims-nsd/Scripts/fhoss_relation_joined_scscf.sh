#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# scscf fhoss relation joined script

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options_scscf" ]; then
	source $SCRIPTS_PATH/default_options_scscf
fi 

if [ -z "$SCRIPTS_PATH" ]; then
	echo "$SERVICE : Using default script path $SCRIPTS_PATH"
	SCRIPTS_PATH="/opt/openbaton/scripts"
else
	echo "$SERVICE : Using custom script path $SCRIPTS_PATH"
fi

VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

# Check for fhoss related information

if [ -z "$fhoss_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no fhoss_name! Using default : hss"
	fhoss_name="hss"
fi

if [ -z "$fhoss_port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no fhoss_port! Using default : 3868"
	fhoss_port="3868"
fi

# Save variables related to bind9 into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "fhoss_name=%s\n" \"$fhoss_name\" >> $VARIABLE_BUCKET
printf "fhoss_port=%s\n" \"$fhoss_port\" >> $VARIABLE_BUCKET
