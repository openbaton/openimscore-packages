#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# Scscf installation script. Icscf is using a local database!

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

export DEBIAN_FRONTEND=noninteractive

# Install packages
install_packages(){
        # Update the apt repository list and install packages
        echo "$SERVICE : Installing packages"
	# Install packages and redirect stderr to our logfile
        apt-get update >> $LOGFILE 2>&1 && apt-get install -q -y $PACKAGES >> $LOGFILE 2>&1
	        echo "$SERVICE : Finished installing packages"
}

if [ ! -d "$INSTALLATION_PATH" ];then
	install_packages
	echo "$SERVICE : Creating directories"
	mkdir $INSTALLATION_PATH
fi
mkdir $LOG_DIR
if [ ! -d "$SER_IMS" ]; then
	# Checkout the source code for OpenIMSCore
	echo "$SERVICE : Checking out source-code"
	svn checkout $SVN_REPO $SER_IMS >> $LOGFILE
	mkdir $BIN_DIR
	mkdir $ETC_DIR
fi
mkdir $INIT_DIR

# move some scripts into their correct place
mv $SCRIPTS_PATH/scscf.conf $INIT_DIR
mv $SCRIPTS_PATH/scscf.* $BIN_DIR
mv $SCRIPTS_PATH/var_scscf.cfg $ETC_DIR
mv $SCRIPTS_PATH/var_scscf.xml $ETC_DIR


# Creation of upstart jobs for running the different components
set_init()
{
        src=$1
        echo "$SERVICE : Setting Service Upstart $src on"
        ln -sf $INSTALLATION_PATH/etc/init/$src.conf /etc/init/$src.conf
        ln -sf /lib/init/upstart-job /etc/init.d/$src
        initctl reload-configuration
}
# Function to compile the OpenIMSCore code
compile()
{
	echo "$SERVICE : compiling OpenIMSCore"
	# Rederict stderr , to avoid spamming the ems log
	cd "$SER_IMS" && make -k install-libs all -j2 >> $LOGFILE 2>&1
}
set_init "$SERVICE"

# check if we need to compile
if [ ! -z "$(ls -A $SER_IMS | grep action.o)" ]; then
	compile
fi
