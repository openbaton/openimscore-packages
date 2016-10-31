#!/bin/bash

ps fax|grep "ser -f" | grep "pcscf.pcc.cfg"| awk '{}{print $0; system("kill -9 " $1);}'

