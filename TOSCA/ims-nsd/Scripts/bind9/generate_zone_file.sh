#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 generate zone file scripts.

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


if [ -z "$realm" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no realm for bind9!"
	exit 1
fi

# Also load variables from the relations
if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
fi

# Copy the zone template file to the final destination
cp $SCRIPTS_PATH/$ZONEFILE $REALMFILE


if [ ! $useFloatingIpsForEntries = "false" ]; then
	if [ -z "$mgmt_floatingIp" ]; then
		echo "$SERVICE : there is no floatingIP for the mgmt network for bind9 !"
		exit 1
	else
		# Else we just overwrite the environment variable
		dns_ip=$mgmt_floatingIp
	fi
else
	dns_ip=$mgmt
fi

# Fill the Bind9 related information
python $SCRIPTS_PATH/substitute.py $REALMFILE VAR_DNS_REALM%$realm
python $SCRIPTS_PATH/substitute.py $REALMFILE VAR_DNS_MGMT%$dns_ip

# Add zone entry 
echo "" >> $CONFIG_FILE
echo "zone \"$realm\" {" >> $CONFIG_FILE
echo "	type master;" >> $CONFIG_FILE
echo "	file \"$REALMFILE\";" >> $CONFIG_FILE
echo "};" >> $CONFIG_FILE
echo "" >> $CONFIG_FILE

