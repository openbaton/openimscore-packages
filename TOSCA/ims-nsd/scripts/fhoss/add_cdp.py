#!/usr/bin/env python
#########################
#	Openbaton	#
#########################
# Author : lgr

# This python script handles adding of cdp peers for OpenIMSCore config files

import sys
import lxml.etree as ET

def main():
  if len(sys.argv) == 6:
      fqdn= sys.argv[1]
      realm = sys.argv[2]
      port = sys.argv[3]
      input_file = sys.argv[4]
      output_file = sys.argv[5]
  parser = ET.XMLParser(strip_cdata=False)
  tree = ET.parse(input_file, parser)
  root = tree.getroot()
  elem = ET.Element("Peer")
  elem.set("FQDN", fqdn + "." + realm)
  elem.set("Realm", realm)
  elem.set("port", port)
  root.insert(0,elem) 
  tree.write (output_file, encoding="utf-8", method="xml", xml_declaration=True , pretty_print=True)

if __name__ == "__main__":
  main()
