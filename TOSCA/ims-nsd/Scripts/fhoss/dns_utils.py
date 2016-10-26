#!/usr/bin/env python
#########################
#	Openbaton	#
#########################

# Script to handle adding additional nameservers

# Author : lgr + oke

import sys
import json
import os
import subprocess
import requests
import time

import shutil
import re

def resolver_adapt_config_light (if_name, dns_server_ip, dns_domain_name, dns_domain_name_openstack):
        interfaces_file_name = '/etc/network/interfaces.d/' + if_name + '.cfg'
        head_file_name = '/etc/resolvconf/resolv.conf.d/head'
        search_str  = '^iface ' + if_name + ' inet dhcp'
        search_line = '  dns-search '
	# Disabled multi realm support...        
	#for entry in dns_domain_name:
        #        search_line = search_line + entry + ' '
	search_line = search_line + ' ' + dns_domain_name
        search_line = search_line + ' ' + dns_domain_name_openstack + '\n'

        # create backup
        shutil.copy2 (interfaces_file_name, interfaces_file_name + '.bak')
        shutil.copy2 (head_file_name, head_file_name + '.bak')
        # Do the dirty adding of our dns_name_server to the head file...
        with open(head_file_name, "a") as head_file:
                head_file.write(os.linesep)
                if dns_server_ip not in open(head_file_name).read():
                        head_file.write("nameserver ")
                        head_file.write(dns_server_ip)
                head_file.write(os.linesep)
        head_file.close()


        # open file and try to match 'search_str'
        interfaces_file = open (interfaces_file_name, 'rw+')
        match_idx = -1
        line_v = interfaces_file.readlines()
        for i in range (len(line_v)):
                line = line_v[i]
                m = re.search (search_str, line)
                # If found, break
                if m is not None:
                        print "DEBUG: found search string"
                        match_idx = i
                        break

        # if found, insert special nameservers line and search line
        if match_idx != -1:
                print "DEBUG: inserting lines"
                #line_v.insert (match_idx + 1, ns_line)
                line_v.insert (match_idx + 2, search_line)

        interfaces_file.seek(0)
        interfaces_file.writelines (line_v)
        interfaces_file.close()

        # Restart network interface via 'initctl'
        #   Pray and hope!
	cmd_str = 'initctl restart network-interface INTERFACE=' + if_name
	ret = subprocess.call (cmd_str.split(' '))


def resolver_restore_backup (if_name):
	#/etc/network/interfaces.d/
	interfaces_file_name = '/etc/network/interfaces.d/'+if_name
	backup_file_name = interfaces_file_name + '.bak'
	# Do not forget our dirty solution!!!
	head_backup_file_name = "/etc/resolvconf/resolv.conf.d/head.bak"

	if os.path.exists (backup_file_name):
		print "DEBUG: restoring backup file " + backup_file_name
		shutil.copy2 (backup_file_name, interfaces_file_name)

		# Restart network interface via 'initctl'
		#   Pray and hope!
		cmd_str = 'initctl restart network-interface INTERFACE=' + if_name
		ret = subprocess.call (cmd_str.split(' '))
	else:
		print "Error: Can't restore backup file " + backup_file_name

	if os.path.exists (head_backup_file_name):
		print "DEBUG: restoring backup file " + head_backup_file_name
		shutil.copy2 (head_backup_file_name, "/etc/resolvconf/resolv.conf.d/head")

		# Restart network interface via 'initctl'
		#   Pray and hope!
		cmd_str = 'initctl restart network-interface INTERFACE=' + if_name
		ret = subprocess.call (cmd_str.split(' '))
	else:
		print "Error: Can't restore backup file " + head_backup_file_name

def replace_resolver_file (dns_server_ip, dns_server_ip_openstack, dns_domain_names):
	resolver_file_name = '/etc/resolv.conf'

	shutil.copy2 (resolver_file_name, resolver_file_name + '.bak')

	resolver_file = open (resolver_file_name, 'w')
	resolver_file.write ('nameserver\t' + dns_server_ip + '\n')
	resolver_file.write ('nameserver\t' + dns_server_ip_openstack + '\n')
	for entry in dns_domain_names:
		resolver_file.write ('search\t'     + entry + '\n')
	resolver_file.close ()
