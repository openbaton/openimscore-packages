#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 scscf relation joined script

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options_fhoss" ]; then
	source $SCRIPTS_PATH/default_options
fi

if [ -z "$SCRIPTS_PATH" ]; then
	echo "$SERVICE : Using default script path $SCRIPTS_PATH"
	SCRIPTS_PATH="/opt/openbaton/scripts"
else
	echo "$SERVICE : Using custom script path $SCRIPTS_PATH"
fi

# Place to store our variables only available during the relation scripts
VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

# Check for icscf related information

if [ -z "$scscf_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no scscf_name! Using default : scscf"
	icscf_name="scscf"
fi

if [ -z "$scscf_port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no scscf_port! Using default : 5060"
	scscf_port="6060"
fi

if [ -z "$scscf_diameter_p" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no scscf_diameter_p! Using default : 3870"
	scscf_diameter_p="3870"
fi

# Save variables related to icscf into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "scscf_name=%s\n" \"$scscf_name\" >> $VARIABLE_BUCKET
printf "scscf_port=%s\n" \"$scscf_port\" >> $VARIABLE_BUCKET
printf "scscf_diameter_p=%s\n" \"$scscf_diameter_p\" >> $VARIABLE_BUCKET

