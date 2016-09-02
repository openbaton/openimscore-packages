#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 scscf relation joined script

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

# Place to store our variables only available during the relation scripts
VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

# Check for icscf related information

if [ -z "$icscf_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no icscf_name! Using default : icscf"
	icscf_name="icscf"
fi

if [ -z "$icscf_diameter_p" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no icscf_diameter_p! Using default : 3869"
	icscf_diameter_p="3869"
fi

# Save variables related to icscf into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "icscf_name=%s\n" \"$icscf_name\" >> $VARIABLE_BUCKET
printf "icscf_diameter_p=%s\n" \"$icscf_diameter_p\" >> $VARIABLE_BUCKET

