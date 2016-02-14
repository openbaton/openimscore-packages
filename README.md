# Use case example: OpenIMSCore - Bind9 - FHoSS
------------------------------------------------

We assume that the [NFVO][nfvo] and the [Generic VNFM](http://openbaton.github.io/documentation/vnfm-generic/) are ready to receive invocations.

The following pictures shows what is going to be deployed, a basic [OpenIMSCore](http://www.openimscore.org/) with a [Home subscriber server](http://www.openimscore.org/) and a [Bind9 nameserver](https://wiki.ubuntuusers.de/DNS-Server_Bind).

![ims-deployment][ims-struc]

Before starting we need to send the [VimInstance](http://openbaton.github.io/documentation/vim-instance/) to the [NFVO][nfvo] and the necessary [Network Service Descriptors][ns-descriptor]. For doing this please have a look into the [Vim instance documentation](http://openbaton.github.io/documentation/vim-instance/), [VNF Package documentation][vnf-package] and [Network Service Descriptor documentation][ns-descriptor]. In fact, for creating the Network Service Record, we need to have a Network Service Descriptor loaded into the catalogue with five [Virtual Network Functions][vnf-descriptor] ( scscf, icscf, pcscf, bind9, fhoss ) created from the [VNF Packages](http://openbaton.github.io/documentation/vnfpackage/). To create the [VNF Packages][vnf-package] please clone the [github repository for this example][openims-repo].

For this example we assume the network used to interconnect the components is called "mgmt", if you want to modify this example ensure you are naming the network accordingly, the scripts from the github do not handle different network names yet. Also the vimInstanceName may be different to you, depending on your setup. The deployment_flavor is optional but should containg enough RAM for the default configuration of the components to be able to run, else some components may crash on start. This example setup has been successfuly tested on clean [Ubuntu14.04 images](https://cloud-images.ubuntu.com/) with 2048 Mb RAM deployed on an [Openstack Kilo (2015.1.3)](https://www.openstack.org/).

The following section will introduce the different [Virtual Network Function Descriptors][vnf-descriptor] used for this example ( which you may already have cloned from the corresponding [github repository](https://github.com/openbaton/openimscore-packages) ). The first descriptor will be explained the rest will be addressed briefly.

## Virtual Network Function Descriptors

Take a look at the Scscf Virtual Network Function Descriptor for this example.

```json
{  
   "name":"scscf",
   "vendor":"fokus",
   "version":"0.1",
   "lifecycle_event":[  
      {  
         "event":"CONFIGURE",
         "lifecycle_events":[  
            "bind9_relation_joined.sh",
            "fhoss_relation_joined.sh",
            "icscf_relation_joined.sh"
         ]
      },
      {  
         "event":"INSTANTIATE",
         "lifecycle_events":[  
            "scscf_install.sh"
         ]
      },
      {  
         "event":"START",
         "lifecycle_events":[  
            "scscf_generate_config.sh",
            "scscf_start.sh"
         ]
      }
   ],
   "configurations":{  
      "name":"client-configuration",
      "configurationParameters":[  
         {  
            "confKey":"port",
            "value":"6060"
         },
         {  
            "confKey":"name",
            "value":"scscf"
         },
         {  
            "confKey":"diameter_p",
            "value":"3870"
         }
      ]
   },
   "vdu":[  
      {  
         "vm_image":[],
         "scale_in_out":1,
         "vnfc":[  
            {  
               "connection_point":[  
                  {  
                     "virtual_link_reference":"mgmt"
                  }
               ]
            }
         ],
         "vimInstanceName":"your_vim"
      }
   ],
   "virtual_link":[  
      {  
         "name":"mgmt"
      }
   ],
   "deployment_flavour":[  
      {  
         "flavour_key":"m1.small"
      }
   ],
   "type":"scscf",
   "endpoint":"generic"
}
```
#### Lifecycle Event
This is how one of the 5 [Virtual Network Functions Descriptors][vnf-descriptor] for this example may look like. In the lifecycle events we listed up all scripts which need to be executed in their related phase. What will actually happen in the scripts is that each descriptor ( scscf, icscf, pcscf, bind9, fhoss ) will install itself and gather information of their dependencies defined in the [Network Service Descriptor][ns-descriptor] to fill a configuration template to build up a correctly configured component of this [OpenIMSCore](http://www.openimscore.org/) setup. Since the template is rather static and probably does not suit your needs you may feel free to modify this example for your needs.

All the scripts provided by openbaton for OpenIMSCore are under Apachee License v2.0


#### Configuration
Each [Virtual Network Function Descriptor][vnf-descriptors] defines specific configuration parameters. In this example we may change the diameter port or the name of some descriptor, or you can alter the [Bind9](https://wiki.ubuntuusers.de/DNS-Server_Bind) realm. This will have impact on the setup of your [OpenIMSCore](http://www.openimscore.org/).
```json
{  
   "confKey":"realm",
   "value":"open-ims.test"
}
```
#### Image and Network
In contrast to the [Iperf example][iperf-example] we do not define the image and leave out the vm image part since we assume the image is already uploaded in the related [Openstack](https://www.openstack.org/) defined in your vim. As mentioned before we will use a network statically named "mgmt". You may change the default name of the image used in this example ( which is "ubuntu-14.04-server-cloudimg-amd64-disk1" ) by modifying the "Metadata.yaml" files of each [Virtual Network Function Package][vnf-package]. You can obtain such a cloud image from the [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)

## Create VNF packages

This section covers up the steps needed to be done to create a vnf package out of the cloned [github repository][openims-repo] of the [OpenIMSCore](http://www.openimscore.org/) [Virtual Network Function Descriptors][vnf-descriptors].


#### Example for creating the Icscf Virtual Network Function Package
```bash
# Where to save the scripts
GIT_REPO_LOC=/opt/vnf_packages_example_openimscore_openbaton
# Clone the repository
git clone https://github.com/openbaton/opemimscore_example $GIT_REPO_LOC
# Create the .tar file which needs to be uploaded
cd $GIT_REPO_LOC/icscf
tar -cf icscf.tar *
```

All we need to do after creating the .tar files is to upload these using your Dashboard. After uploading all the Virtual Network Function Packages we will be ready to create the Network Service Descriptor.

## Network Service Descriptor for OpenIMSCore - Bind9 - FHoSS

#### Relations / Dependencies
In the Network Service Descriptor we will define the relations among our Virtual Network Function Descriptors. Since 4 of the 5 Virtual Network Function Descriptors ( Scscf, Icscf, FHoSS, Bind9 ) are all dependend on each other, the listing of the dependencies can get confusing. 

For this example the Network Service Descriptor may look like the following.
```json
{
   "name":"OpenIMSCore Bind9 FHoSS",
   "vendor":"fokus",
   "version":"0.1-ALPHA",
   "vnfd":[  
      {  
         "id":"26b588d5-ecb9-4bf2-a044-720ad1100e58"
      },
      {  
         "id":"bd422c42-2343-4769-830d-0e92bbe54dc8"
      },
      {  
         "id":"c1933ff3-4b55-4eb1-97b7-8ca9675b2067"
      },
      {  
         "id":"f57bb94d-e307-4048-8bc6-7547f9b40f6a"
      },
      {  
         "id":"f8d821ed-f7ee-4ae8-a660-b885780c28df"
      }
   ],
   "vld":[  
      {  
         "name":"mgmt"
      }
   ],
   "vnf_dependency":[  
      {  
         "source":{  
            "name":"bind9"
         },
         "target":{  
            "name":"fhoss"
         },
         "parameters":[  
            "realm"
         ]
      },
      {  
         "source":{  
            "name":"bind9"
         },
         "target":{  
            "name":"icscf"
         },
         "parameters":[  
            "realm"
         ]
      },
      {  
         "source":{  
            "name":"bind9"
         },
         "target":{  
            "name":"scscf"
         },
         "parameters":[  
            "realm"
         ]
      },
      {  
         "source":{  
            "name":"bind9"
         },
         "target":{  
            "name":"pcscf"
         },
         "parameters":[  
            "realm"
         ]
      },
      {  
         "source":{  
            "name":"fhoss"
         },
         "target":{  
            "name":"bind9"
         },
         "parameters":[  
            "name"
         ]
      },
      {  
         "source":{  
            "name":"icscf"
         },
         "target":{  
            "name":"bind9"
         },
         "parameters":[  
            "name",
            "port"
         ]
      },
      {  
         "source":{  
            "name":"scscf"
         },
         "target":{  
            "name":"bind9"
         },
         "parameters":[  
            "name",
            "port"
         ]
      },
      {  
         "source":{  
            "name":"pcscf"
         },
         "target":{  
            "name":"bind9"
         },
         "parameters":[  
            "name",
            "port"
         ]
      },
      {  
         "source":{  
            "name":"fhoss"
         },
         "target":{  
            "name":"icscf"
         },
         "parameters":[  
            "name",
            "port"
         ]
      },
      {  
         "source":{  
            "name":"fhoss"
         },
         "target":{  
            "name":"scscf"
         },
         "parameters":[  
            "name",
            "port"
         ]
      },
      {  
         "source":{  
            "name":"scscf"
         },
         "target":{  
            "name":"fhoss"
         },
         "parameters":[  
            "name",
            "port",
            "diameter_p"
         ]
      },
      {  
         "source":{  
            "name":"icscf"
         },
         "target":{  
            "name":"fhoss"
         },
         "parameters":[  
            "name",
            "diameter_p"
         ]
      },
      {  
         "source":{  
            "name":"scscf"
         },
         "target":{  
            "name":"icscf"
         },
         "parameters":[  
            "name",
            "port"
         ]
      },
      {  
         "source":{  
            "name":"icscf"
         },
         "target":{  
            "name":"scscf"
         },
         "parameters":[  
            "name"
         ]
      }
   ]
}
```

Assuming we have uploaded all Virtual Network Function Packages, the ids for the Virtual Network Function Descriptors are to be found in your dashboard or directly accessed via your API at http://nfvo-ip:8080/api/v1/vnf-descriptors. 

For continuous testing of your network services you may find it helpful to use this python script printing the Virtual Network Function Descriptor ids. Be aware, this script only works if you disabled the security in the NFVO. So you can easily copy paste the script output into your Network Service Descriptor.
```python
#!/usr/bin/env python

import json
import sys
import getopt
import urllib2

program_name="./getVnfDescriptors"

def main(argv):
        ip="127.0.0.1"
        try:
                opts, args = getopt.getopt(argv,"hi:",["ip="])
        except getopt.GetoptError:
                print usage
                sys.exit(2)
        for opt, arg in opts:
                if opt == '-h':
                        print program_name + " -i <ip>"
                        sys.exit()
                elif opt in ("-i", "--ip"):
                        ip = arg
        data = json.load(urllib2.urlopen('http://'+ip+':8080/api/v1/vnf-descriptors'))
        for i in data:
                print "         {"
                print "                 \"id\":\"" +i["id"] + "\""
                # check that we do not have the last entry
                if i["id"] == data[-1]["id"]:
                        print "         }"
                else:
                        print "         },"

if __name__ == "__main__":
        main(sys.argv[1:])
```

The next step is to upload your Network Service Descriptor via the dashboard.

## Launching the NSD

Now that we have uploaded the Network Service Descriptor we can launch it. You can watch the progress checking the Network Service Records on your dashboard. Once the Network Service Record went to "ACTIVE" your [OpenIMSCore](http://www.openimscore.org/) - [Bind9](https://wiki.ubuntuusers.de/DNS-Server_Bind) - [FHoSS](http://www.openimscore.org/) deployment is finished.

## Testing your Deployment

To test your [OpenIMSCore](http://www.openimscore.org/) you may use a Sip client of your choice. Be sure to use the realm defined in your [Bind9 Virtual Network Function Descriptor](https://github.com/openbaton/opemimscore_example/bind9) while testing registration and call. By default the [FHoSS](http://www.openimscore.org/) conaints 2 users : alice and bob. The user is the same as the password, but you may also alter it to your needs modifying the [FHoSS Virtual Network Function Descriptor][openims-repo] ( You will find the users in "var_user_data.sql" file under the fhoss folder)

For Benchmarking we can use [IMS Bench SIPp](http://sipp.sourceforge.net/ims_bench/) but therefor you should add more users to the [FHoSS](http://www.openimscore.org/) database since by default it only contains 2 users.


[ims-struc]:images/ims-architecture.png
[nfvo]:http://openbaton.github.io/documentation/nfvo-installation/
[vnf-package]:http://openbaton.github.io/documentation/vnfpackage/
[vnf-descriptors]:http://openbaton.github.io/documentation/vnf-descriptor/
[ns-descriptor]:http://openbaton.github.io/documentation/ns-descriptor/
[iperf-example]:./use-case-example.md
[openims-repo]:https://github.com/openbaton/openimscore-packages
