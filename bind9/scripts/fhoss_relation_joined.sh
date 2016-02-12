#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 fhoss relation joined script

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

# Check for fhoss related information

if [ -z "$fhoss_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no fhoss_name! Using default : hss"
	fhoss_name="hss"
fi

if [ -z "$fhoss_mgmt" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no mgmt network for fhoss !"
	exit 1
fi

# Check if we want to use floatingIPs for the entries
echo "$SERVICE : useFloatingIpsForEntries : $useFloatingIpsForEntries for fhoss"
if [ ! $useFloatingIpsForEntries = "false" ]; then
	if [ -z "$fhoss_mgmt_floatingIp" ]; then
		echo "$SERVICE : there is no floatingIP for the mgmt network for fhoss !"
		#exit 1
	else
		# Else we just overwrite the environment variable
		fhoss_mgmt=$fhoss_mgmt_floatingIp
	fi
fi


# Save variables related to icscf into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "fhoss_name=%s\n" \"$fhoss_name\" >> $VARIABLE_BUCKET
printf "fhoss_mgmt=%s\n" \"$fhoss_mgmt\" >> $VARIABLE_BUCKET

# Fill up the template dns zone file with the necessary entries
cat >>$SCRIPTS_PATH/$ZONEFILE <<EOL
$fhoss_name.$realm. IN A $fhoss_mgmt
EOL

