#!/bin/bash

ps fax|grep "ser -f" | grep "pcscf.cfg"| awk '{}{print $0; system("kill -2 " $1);}'

