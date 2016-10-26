#!/bin/bash

cd /opt/OpenIMSCore/bin
./pcscf.pcc.stop.sh

cd /opt/OpenIMSCore/ser_ims

screen -S pcscf.pcc -d -m -h 10000 /bin/bash -c "LD_LIBRARY_PATH=/usr/local/lib/ser ./ser -f /opt/OpenIMSCore/etc/pcscf.pcc.cfg -D -D"

screen -wipe
