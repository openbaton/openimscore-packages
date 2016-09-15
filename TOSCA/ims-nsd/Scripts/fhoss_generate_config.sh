#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# fhoss generate config script.

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options_fhoss" ]; then
	source $SCRIPTS_PATH/default_options_fhoss
fi 

if [ -z "$SCRIPTS_PATH" ]; then
	echo "$SERVICE : Using default script path $SCRIPTS_PATH"
	SCRIPTS_PATH="/opt/openbaton/scripts"
else
	echo "$SERVICE : Using custom script path $SCRIPTS_PATH"
fi

# Check for specific config values of the fhoss
if [ -z "$diameter_p" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : diameter_p not defined, will use default : 3868"
	diameter_p="3868"
fi
# Check for specific config values of the fhoss
if [ -z "$name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : name not defined, will use default : hss"
	name="hss"
fi

VARIABLE_BUCKET="$SCRIPTS_PATH/.variables"

HSS_VARIABLE_USERS_FILE="$SCRIPTS_PATH/var_user_data.sql"
HSS_VARIABLE_DIAMETER_PEER="$SCRIPTS_PATH/var_dia_peer.xml"

if [ -f "$VARIABLE_BUCKET" ]; then
	source $VARIABLE_BUCKET
fi

if [ -z "$realm" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no realm for bind9!"
	exit 1
fi

if [ -z "$scscf_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no name for scscf!"
	exit 1
fi

if [ -z "$scscf_port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no port for scscf!"
	exit 1
fi

if [ -z "$scscf_diameter_p" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no diameter_p for scscf!"
	exit 1
fi

if [ -z "$icscf_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no name for icscf!"
	exit 1
fi

if [ -z "$icscf_diameter_p" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no diameter_p for icscf!"
	exit 1
fi

# First thing to do is to add the cdp peer to the icscf,scscf to our template config file
if [ -f "$HSS_VARIABLE_DIAMETER_PEER" ];then
	echo "$SERVICE : Adding fqdn to xml config"
	python $SCRIPTS_PATH/$ADD_CDP_SCRIPT $icscf_name $realm $icscf_diameter_p $HSS_VARIABLE_DIAMETER_PEER $HSS_VARIABLE_DIAMETER_PEER
	python $SCRIPTS_PATH/$ADD_CDP_SCRIPT $scscf_name $realm $scscf_diameter_p $HSS_VARIABLE_DIAMETER_PEER $HSS_VARIABLE_DIAMETER_PEER
fi

# Copy our template files to the correct location
if [ -f "$HSS_USERS_FILE" ];then
	rm $HSS_USERS_FILE
fi
cp $HSS_VARIABLE_USERS_FILE $HSS_USERS_FILE	
if [ -f "$HSS_DIAMETER_PEER_FILE" ];then
	rm $HSS_DIAMETER_PEER_FILE
fi
cp $HSS_VARIABLE_DIAMETER_PEER $HSS_DIAMETER_PEER_FILE	

# Fill the templates
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $HSS_VARIABLE_USERS_FILE VAR_DNS_REALM%$realm
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $HSS_VARIABLE_USERS_FILE VAR_SCSCF_NAME%$scscf_name
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $HSS_VARIABLE_USERS_FILE VAR_SCSCF_PORT%$scscf_port
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $HSS_DIAMETER_PEER_FILE VAR_DNS_REALM%$realm
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $HSS_DIAMETER_PEER_FILE VAR_FHOSS_NAME%$name
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $HSS_DIAMETER_PEER_FILE VAR_FHOSS_DIA_PORT%$diameter_p
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $HSS_DIAMETER_PEER_FILE VAR_FHOSS_DIA_BIND%$mgmt

# now finally import userdata.sql since it has been overwritten

mysql -u root < $HSS_VARIABLE_USERS_FILE

# Do not forget to replace the diameter file :)
mv $HSS_DIAMETER_PEER_FILE $HSS_ORIG_DIAMETER_PEER_FILE
