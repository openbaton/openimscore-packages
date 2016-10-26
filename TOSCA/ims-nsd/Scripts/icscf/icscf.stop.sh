#!/bin/bash

ps fax|grep "ser -f" | grep "icscf.cfg"| awk '{}{print $0; system("kill -2 " $1);}'

