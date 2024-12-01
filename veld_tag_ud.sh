#!/bin/bash

# This script is a wrapper for the underlying xmlanntools script. It handles input and output files,
# respective to the VELD design, and also constructs a command from the VELD compose file, which is
# then executed.

set -e

command="./tag_ud -f /veld/input/${in_txt_file}"

if [ -n "$model" ]; then
  command+=" -m ${model}"
fi

if [ -n "$batch" ]; then
  command+=" -b ${batch}"
fi

if [ "$verbose" = "true" ]; then
  command+=" -v"
fi

command+=" > /veld/output/${out_conllu_file}"

echo "executing:"
echo "$command"
eval "$command"

