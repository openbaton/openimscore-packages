#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 scscf relation joined script

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options_bind9" ]; then
	source $SCRIPTS_PATH/default_options_bind9
fi

if [ -z "$SCRIPTS_PATH" ]; then
	echo "$SERVICE : Using default script path $SCRIPTS_PATH"
	SCRIPTS_PATH="/opt/openbaton/scripts"
else
	echo "$SERVICE : Using custom script path $SCRIPTS_PATH"
fi

VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

# Check for pcscf related information

if [ -z "$pcscf_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no pcscf_name! Using default : pcscf"
	pcscf_name="pcscf"
fi

if [ -z "$pcscf_port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no pcscf_port! Using default : 4060"
	icscf_port="4060"
fi

if [ -z "$pcscf_mgmt" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no mgmt network for pcscf !"
	exit 1
fi

# Check if we want to use floatingIPs for the entries
echo "$SERVICE : useFloatingIpsForEntries : $useFloatingIpsForEntries for pcscf"
if [ ! $useFloatingIpsForEntries = "false" ]; then
	if [ -z "$pcscf_mgmt_floatingIp" ]; then
		echo "$SERVICE : there is no floatingIP for the mgmt network for pcscf !"
		#exit 1
	else
		# Else we just overwrite the environment variable
		pcscf_mgmt=$pcscf_mgmt_floatingIp
	fi
fi

# Save variables related to icscf into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "pcscf_name=%s\n" \"$pcscf_name\" >> $VARIABLE_BUCKET
printf "pcscf_port=%s\n" \"$pcscf_port\" >> $VARIABLE_BUCKET
printf "pcscf_mgmt=%s\n" \"$pcscf_mgmt\" >> $VARIABLE_BUCKET

# Fill up the template dns zone file with the necessary entries
cat >>$SCRIPTS_PATH/$ZONEFILE <<EOL
$pcscf_name-rf.$realm.  IN A  $pcscf_mgmt
$pcscf_name-rx.$realm.  IN A  $pcscf_mgmt
$pcscf_name.$realm.  IN A  $pcscf_mgmt
$pcscf_name-rxrf.$realm.  IN A  $pcscf_mgmt
_sip.$pcscf_name.$realm.  IN SRV 1 0 $pcscf_port $pcscf_name.$realm.
_sip._udp.$pcscf_name.$realm.  IN SRV 1 0 $pcscf_port $pcscf_name.$realm.
_sip._tcp.$pcscf_name.$realm.  IN SRV 1 0 $pcscf_port $pcscf_name.$realm.
EOL
