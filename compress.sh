#!/bin/bash

dest="../tars"

if [ ! -d "$dest" ]; then
	 mkdir $dest 
fi

pushd bind9
tar -cvf $dest/bind9.tar Metadata.yaml vnfd.json scripts
popd
pushd icscf
tar -cvf $dest/icscf.tar Metadata.yaml vnfd.json scripts
popd
pushd pcscf
tar -cvf $dest/pcscf.tar Metadata.yaml vnfd.json scripts
popd
pushd scscf
tar -cvf $dest/scscf.tar Metadata.yaml vnfd.json scripts
popd
pushd fhoss
tar -cvf $dest/fhoss.tar Metadata.yaml vnfd.json scripts
popd
