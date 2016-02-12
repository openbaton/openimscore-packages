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

VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

# Check for scscf related information

if [ -z "$scscf_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no scscf_name! Using default : scscf"
	scscf_name="scscf"
fi

if [ -z "$scscf_port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no scscf_port! Using default : 5060"
	scscf_port="5060"
fi

if [ -z "$scscf_mgmt" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no mgmt network for scscf !"
	exit 1
fi

# Check if we want to use floatingIPs for the entries
echo "$SERVICE : useFloatingIpsForEntries : $useFloatingIpsForEntries for scscf"
if [ ! $useFloatingIpsForEntries = "false" ]; then
	if [ -z "$scscf_mgmt_floatingIp" ]; then
		echo "$SERVICE : there is no floatingIP for the mgmt network for scscf !"
		#exit 1
	else
		# Else we just overwrite the environment variable
		scscf_mgmt=$scscf_mgmt_floatingIp
	fi
fi

# Save variables related to icscf into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "scscf_name=%s\n" \"$scscf_name\" >> $VARIABLE_BUCKET
printf "scscf_port=%s\n" \"$scscf_port\" >> $VARIABLE_BUCKET
printf "scscf_mgmt=%s\n" \"$scscf_mgmt\" >> $VARIABLE_BUCKET

# Fill up the template dns zone file with the necessary entries
cat >>$SCRIPTS_PATH/$ZONEFILE <<EOL
$scscf_name.$realm.  IN A  $scscf_mgmt
$scscf_name-cx.$realm.  IN A  $scscf_mgmt
$scscf_name-cxrf.$realm.  IN A  $scscf_mgmt
_sip.$scscf_name.$realm.  IN SRV 1 0 $scscf_port $scscf_name.$realm.
_sip._udp.$scscf_name.$realm.  IN SRV 1 0 $scscf_port $scscf_name.$realm.
_sip._tcp.$scscf_name.$realm.  IN SRV 1 0 $scscf_port $scscf_name.$realm.
EOL
