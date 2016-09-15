#!/bin/bash
#########################
#	Openbaton	#
#########################
# Author : lgr

# Icscf installation script. Icscf is using a local database!

# If there are default options load them 
if [ -f "$SCRIPTS_PATH/default_options_icscf" ]; then
	source $SCRIPTS_PATH/default_options_icscf
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
	# Set env variables so mysql will not ask for password when being installed
	export DEBIAN_FRONTEND=noninteractive
	# Install packages and redirect stderr to our logfile
        apt-get update >> $LOGFILE 2>&1 && apt-get install -q -y $PACKAGES >> $LOGFILE 2>&1
        echo "$SERVICE : Finished installing packages"
}

install_packages

if [ ! -d "$INSTALLATION_PATH" ];then
	echo "$SERVICE : Creating directories"
	mkdir $INSTALLATION_PATH
	mkdir $LOG_DIR
fi

# Checkout the source code for OpenIMSCore
echo "$SERVICE : Checking out source-code"
svn checkout $SVN_REPO $SER_IMS >> $LOGFILE

mkdir $BIN_DIR
mkdir $ETC_DIR
mkdir $SQL_DIR
mkdir $INIT_DIR

# move some scripts into their correct place
mv $SCRIPTS_PATH/icscf.conf $INIT_DIR
mv $SCRIPTS_PATH/icscf.* $BIN_DIR
mv $SCRIPTS_PATH/var_icscf.cfg $ETC_DIR
mv $SCRIPTS_PATH/var_icscf.xml $ETC_DIR
mv $SCRIPTS_PATH/var_icscf.sql $SQL_DIR


# Creation of upstart jobs for running the different components
set_init()
{
        src=$1
        echo "Setting Service Upstart $src on"
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
compile
