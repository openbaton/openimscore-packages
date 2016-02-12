#########################
#	Openbaton	#
#########################
# Author : lgr

# This script can handle substition of any string in any file

import sys
import os

def replace_gen_vars(line):
  for k,v in gen_var_dict.iteritems():
    line = line.replace(k,v)
  return line

def main():
  global ARG_LIST
  global gen_var_dict

  # Create an empty dictionary
  gen_var_dict = {}

  # First Argument is always the file to be substituted

  # Get arguments and put them into the dictionary
  # Splitting by "%" sign , so the first half contains
  # the string to search for , the second half contains
  # the string to be inserted

  ARG_LIST = sys.argv
  del ARG_LIST[0]
  cfg_input_file = ARG_LIST[0]
  cfg_output_file = cfg_input_file
  del ARG_LIST[0]
  for entry in ARG_LIST:
        values = entry.split("%");
        gen_var_dict[values[0]] = values[1]

  with open(cfg_input_file) as f:
    file_lines = f.readlines()
    new_file = [replace_gen_vars(line) for line in file_lines]

  open(cfg_output_file,"w").write(''.join(new_file))

if __name__ == "__main__":
  main()

