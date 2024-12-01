#!/bin/bash

set -e

command="./xml2standoff /veld/input/${in_xml_file}"

if [ -n "$text_elements" ]; then
  command+=" -t ${text_elements}"
fi

if [ -n "$exclude_elements" ]; then
  command+=" -e ${exclude_elements}"
fi

if [ "$keep_linebreaks" = "true" ]; then
  command+=" -kl"
fi

echo "executing:"
echo "$command"
eval "$command"

set +e

out_txt_file_generated="${in_xml_file%.xml}.txt"
if [ -n "$out_txt_file" ]; then
  mv /veld/input/"$out_txt_file_generated" /veld/output/"$out_txt_file" 2> /dev/null
else
  mv /veld/input/"$out_txt_file_generated" /veld/output/ 2> /dev/null
fi

out_json_file_generated="${in_xml_file%.xml}.json"
if [ -n "$out_json_file" ]; then
  mv /veld/input/"$out_json_file_generated" /veld/output/"$out_json_file" 2> /dev/null
else
  mv /veld/input/"$out_json_file_generated" /veld/output/ 2> /dev/null
fi

exit 0

