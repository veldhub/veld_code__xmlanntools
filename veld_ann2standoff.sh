#!/bin/bash

cp /veld/input/"$in_conllu_file" /veld/output/
in_txt_file_ensured="${in_conllu_file%.conllu}.txt"
cp /veld/input/"$in_txt_file" /veld/output/"$in_txt_file_ensured"

command="./ann2standoff /veld/output/${in_conllu_file}"

if [ -n "$in_ann2standoff_ini_file" ]; then
  command+=" -c /veld/input/${in_ann2standoff_ini_file}"
fi

if [ -n "$profile_name" ]; then
  command+=" -p ${profile_name}"
fi

echo "executing:"
echo "$command"
eval "$command"

rm /veld/output/"$in_conllu_file"
rm /veld/output/"$in_txt_file_ensured"

