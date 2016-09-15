#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# fhoss installation script.

# fhoss will be configured to use a local database!

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options_fhoss"]; then
	source $SCRIPTS_PATH/default_options_fhoss
fi 

if [ -z "$SCRIPTS_PATH" ]; then
	echo "$SERVICE : Using default script path $SCRIPTS_PATH"
	SCRIPTS_PATH="/opt/openbaton/scripts"
else
	echo "$SERVICE : Using custom script path $SCRIPTS_PATH"
fi

# Start a screen session with the component

export PATH=$PATH:$JAVA_BIN_PATH
export JAVA_HOME="$JAVA_PATH"

screen -dmS fhoss
sleep 0.5s
screen -S fhoss -X screen /bin/bash -c "cd $DEPLOY_DIR/ && ./startup.sh"
