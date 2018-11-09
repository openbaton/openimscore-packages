#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# bind9 installation script.

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options" ]; then
        echo "realm=$realm" >> $SCRIPTS_PATH/default_options
	source $SCRIPTS_PATH/default_options
fi

echo "$SERVICE : Installing packages"
# Install packages and redirect stderr to our logfile
apt-get update >> $LOGFILE 2>&1 && echo "$SERVICE : Finished update now installing packages" && apt-get install -y -q bind9 >> $LOGFILE 2>&1
echo "$SERVICE : Finished installing packages"
