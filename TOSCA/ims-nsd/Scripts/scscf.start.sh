#!/bin/bash

cd /opt/OpenIMSCore/bin
./scscf.stop.sh

cd /opt/OpenIMSCore/ser_ims

screen -S scscf -d -m -h 10000 /bin/bash -c "LD_LIBRARY_PATH=/usr/local/lib/ser ./ser -f /opt/OpenIMSCore/etc/scscf.cfg -D -D"

screen -wipe || true
