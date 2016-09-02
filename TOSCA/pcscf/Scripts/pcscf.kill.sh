#!/bin/bash

ps fax|grep "ser -f" | grep "pcscf.cfg"| awk '{}{print $0; system("kill -9 " $1);}'
screen -wipe || /bin/true

