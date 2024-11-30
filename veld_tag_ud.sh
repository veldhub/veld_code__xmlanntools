#!/bin/bash

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

