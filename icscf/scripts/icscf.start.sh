#!/bin/bash

cd /opt/OpenIMSCore/bin
./icscf.stop.sh

cd /opt/OpenIMSCore/ser_ims

screen -S icscf -d -m -h 10000 /bin/bash -c "LD_LIBRARY_PATH=/usr/local/lib/ser ./ser -f /opt/OpenIMSCore/etc/icscf.cfg -D -D"

screen -wipe || true
