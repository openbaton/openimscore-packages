#!/usr/bin/env python
#########################
#	Openbaton	#
#########################
# Author : lgr

import sys
import os
import shutil

# Will create a copy of the existing file in the same directory ( ending with .back)
def create_backup (file_name):
	shutil.copy2 (file_name, file_name + '.bak')

# Assumes file ends with .back
def restore_backup (file_name):
	shutil.copy2 (file_name + '.bak', file_name)
