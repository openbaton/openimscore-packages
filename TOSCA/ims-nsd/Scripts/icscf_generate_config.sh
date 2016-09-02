#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# icscf generate config script

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

# Check for variables
if [ -z "$port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : port not defined, will use default : 6060"
	port="6060"
fi

if [ -z "$diameter_p" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : diameter_p not defined, will use default : 3869"
	diameter_p="3869"
fi

if [ -z "$name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : name not defined, will use default : icscf"
	name="icscf"
fi

if [ -z "$mgmt" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is not mgmt network!"
	exit 1
fi


# Also load variables from the relations

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

if [ -z "$fhoss_name" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no name for fhoss!"
	exit 1
fi

if [ -z "$fhoss_port" ]; then
	# Actually this case should not happen, only if you renamed the config values ;)
	echo "$SERVICE : there is no port for fhoss!"
	exit 1
fi


# First thing to do is to add the cdp peer to the hss to our template config file
if [ -f "$XML_INPUT_FILE" ];then
	python $SCRIPTS_PATH/$ADD_CDP_SCRIPT $fhoss_name $realm $fhoss_port $XML_INPUT_FILE $XML_INPUT_FILE
fi


# Prepare a variable containing the hostname used in the bind9 nameserver

bind9_entry=$name.$realm
fhoss_entry=$fhoss_name.$realm

# Prepare a variable containing the bind9 realm with outslashed points
slashed_rea=$(echo $realm | sed s/\\./\\\\./g)

# Copy our templates to the correct locations

cp $XML_INPUT_FILE $XML_OUTPUT_FILE
cp $CFG_INPUT_FILE $CFG_OUTPUT_FILE
cp $SQL_INPUT_FILE $SQL_OUTPUT_FILE

# Fill the templates

python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_DIAMETER_LISTEN%$mgmt
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_ICSCF_PORT%$port
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_DNS_ENTRY%$bind9_entry
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_DNS_REALM%$realm
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_HSS_ENTRY%$fhoss_entry
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $CFG_OUTPUT_FILE VAR_DNS_REA_SLASHED%$slashed_rea

python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $SQL_OUTPUT_FILE VAR_DNS_REALM%$realm
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $SQL_OUTPUT_FILE VAR_SCSCF_NAME%$scscf_name
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $SQL_OUTPUT_FILE VAR_SCSCF_PORT%$scscf_port

python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $XML_OUTPUT_FILE VAR_DNS_REALM%$realm
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $XML_OUTPUT_FILE VAR_DNS_ENTRY%$bind9_entry
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $XML_OUTPUT_FILE VAR_DIAMETER_LISTEN%$mgmt
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $XML_OUTPUT_FILE VAR_DIAMETER_PORT%$diameter_p
python $SCRIPTS_PATH/$SUBSITUTE_SCRIPT $XML_OUTPUT_FILE VAR_DEFAULT_ROUTE%$fhoss_entry

prepare_mysql()
{
	service mysql restart
	mysql -u root -e "create database if not exists icscf;"
	mysql -u root -e "grant delete,insert,select,update on icscf.* to icscf@localhost IDENTIFIED BY 'heslo';"
	mysql -u root -e "grant delete,insert,select,update on icscf.* to icscf@$mgmt IDENTIFIED BY 'heslo';"
	mysql -u root -h localhost < $INSTALLATION_PATH/etc/sql/icscf.sql
}

# import database !
prepare_mysql

