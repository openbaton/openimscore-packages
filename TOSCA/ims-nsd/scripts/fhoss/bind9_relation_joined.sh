#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# fhoss bind9 relation joined script

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

# Check for bind9 realm related information
if [ -z "$bind9_realm" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : bind9_realm not defined, will use default : openims.test"
	bind9_realm="openims.test"
fi

# Check if fhoss got a ipv4 address on the mgmt network
if [ -z "$mgmt" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is not mgmt network!"
	exit 1
fi

# Check for bind9 realm related information
if [ -z "$bind9_mgmt" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is not mgmt network for bind9!"
	exit 1
fi

# Check for bind9 realm related information
if [ ! -z "$bind9_useFloatingIpsForEntries" ]; then
	echo "$SERVICE : bind9_useFloatingIpsForEntries : $bind9_useFloatingIpsForEntries"
	if [ ! $bind9_useFloatingIpsForEntries = "false" ]; then
		if [ -z "$bind9_mgmt_floatingIp" ]; then
			echo "$SERVICE : there is no floatingIP for the mgmt network for bind9 !"
			exit 1
		else
			# Else we just overwrite the environment variable
			bind9_mgmt=$bind9_mgmt_floatingIp
		fi
	fi
fi

# Get the own ipv4 address ( We assume it is called "mgmt" here! )
IPV4_ADDRESS=$mgmt

# Get the bind9 ipv4 address ( We assume it is called "mgmt" here! )
BIND9_IP=$bind9_mgmt

# Save variables related to bind9 into a file to access it in a later phase
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
else
	touch $VARIABLE_BUCKET
fi
printf "realm=%s\n" \"$bind9_realm\" >> $VARIABLE_BUCKET

echo "$SERVICE: Establishing nameserver"

# Get the network interface name to be able to add a search line to it permanently
_real_iface=$(ip addr | grep -B 2 "$IPV4_ADDRESS" | head -1 | awk '{ print $2 }' | sed 's/://')

# Use a python function to adapt the /etc/resolv.conf permanently
# What we will do is the write the new bind9 nameserver into the head file...
# Thus we ensure it will always be the first nameserver in the /etc/resolv.conf
cd $SCRIPTS_PATH && python << END
import dns_utils
dns_utils.resolver_adapt_config_light("$_real_iface","$BIND9_IP","$bind9_realm", 'novalocal.')
END

# Update the /etc/resolv.conf to be sure we have added the new nameserver
resolvconf -u
