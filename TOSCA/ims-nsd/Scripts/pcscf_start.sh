#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options_pcscf" ]; then
	source $SCRIPTS_PATH/default_options_pcscf
fi 

# pcscf start script

# Check if there was a icscf running already
check=$(status $SERVICE | grep running)
if [ -z "$check" ];then
	echo "$SERVICE : not running , will start"
	start $SERVICE
else
	echo "$SERVICE:  already running! Will restart"
	restart $SERVICE
fi

