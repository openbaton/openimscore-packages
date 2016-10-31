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

# Check for icscf related information

if [ -z "$icscf_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no icscf_name! Using default : icscf"
	icscf_name="icscf"
fi

if [ -z "$icscf_port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no icscf_port! Using default : 6060"
	icscf_port="6060"
fi

if [ -z "$icscf_mgmt" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no mgmt network for icscf !"
	exit 1
fi

# Check if we want to use floatingIPs for the entries
echo "$SERVICE : useFloatingIpsForEntries : $useFloatingIpsForEntries for icscf"
if [ ! $useFloatingIpsForEntries = "false" ]; then
	if [ -z "$icscf_mgmt_floatingIp" ]; then
		echo "$SERVICE : there is no floatingIP for the mgmt network for icscf !"
		#exit 1
	else
		# Else we just overwrite the environment variable
		icscf_mgmt=$icscf_mgmt_floatingIp
	fi
fi

# Save variables related to icscf into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "icscf_name=%s\n" \"$icscf_name\" >> $VARIABLE_BUCKET
printf "icscf_port=%s\n" \"$icscf_port\" >> $VARIABLE_BUCKET
printf "icscf_mgmt=%s\n" \"$icscf_mgmt\" >> $VARIABLE_BUCKET


# Fill up the template dns zone file with the necessary entries
cat >>$SCRIPTS_PATH/$ZONEFILE <<EOL
$icscf_name.$realm.  IN A  $icscf_mgmt
$icscf_name-cx.$realm.  IN A  $icscf_mgmt
_sip.$icscf_name.$realm.  IN SRV 1 0 $icscf_port $icscf_name.$realm.
_sip._udp.$icscf_name.$realm.  IN SRV 1 0 $icscf_port $icscf_name.$realm.
_sip._tcp.$icscf_name.$realm.  IN SRV 1 0 $icscf_port $icscf_name.$realm.
_sip.$realm.  IN SRV 1 0 $icscf_port $realm.
_sip._udp.$realm.  IN SRV 1 0 $icscf_port $realm.
_sip._tcp.$realm.  IN SRV 1 0 $icscf_port $realm.
$realm.  IN A  $icscf_mgmt
$realm.  IN NAPTR 10 50 "s" "SIP+D2U" "" _sip._udp
$realm.  IN NAPTR 20 50 "s" "SIP+D2U" "" _sip._tcp
EOL

