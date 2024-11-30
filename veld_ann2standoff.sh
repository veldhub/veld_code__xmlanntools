#!/bin/bash

set -e

in_txt_file_expected="${in_conllu_file%.conllu}.txt"
if [ -n "$in_txt_file" ] && [ $in_txt_file != $in_txt_file_expected ]; then
  cp /veld/input/"$in_txt_file" /veld/input/"$in_txt_file_expected"
  rm_txt_file=1
fi

command="./ann2standoff /veld/input/${in_conllu_file}"

if [ -n "$in_ann2standoff_ini_file" ]; then
  command+=" -c /veld/input/${in_ann2standoff_ini_file}"
fi

if [ -n "$profile_name" ]; then
  command+=" -p ${profile_name}"
fi

echo "executing:"
echo "$command"
eval "$command"

if [ "$rm_txt_file" = "1" ]; then
  rm /veld/input/"$in_txt_file_expected"
fi

out_json_file_generated="${in_conllu_file%.conllu}.ann.json"
if [ -n "$out_json_file" ]; then
  mv /veld/input/"$out_json_file_generated" /veld/output/"$out_json_file"
else
  mv /veld/input/"$out_json_file_generated" /veld/output/
fi

