#!/bin/bash

cd /opt/OpenIMSCore/bin
./pcscf.stop.sh

cd /opt/OpenIMSCore/ser_ims

screen -S pcscf -d -m -h 10000 /bin/bash -c "LD_LIBRARY_PATH=/usr/local/lib/ser ./ser -f /opt/OpenIMSCore/etc/pcscf.cfg -D -D"

screen -wipe || true
