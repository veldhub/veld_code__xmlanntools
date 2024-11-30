#!/bin/bash

cp /veld/input/$in_xml_file /veld/output/

command="./xml2standoff /veld/output/${in_xml_file}"

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

rm /veld/output/$in_xml_file

