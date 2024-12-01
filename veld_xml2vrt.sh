#!/bin/bash

set -e

command="./xml2vrt /veld/input/data/${in_ann_xml_file}"

if [ -n "$in_ann2standoff_ini_file" ]; then
  command+=" -c /veld/input/config/${in_ann2standoff_ini_file}"
fi

if [ -n "$profile_name" ]; then
  command+=" -p ${profile_name}"
fi

if [ -n "$attributes" ]; then
  command+=" -a ${attributes}"
fi

if [ -n "$token_element" ]; then
  command+=" -te ${token_element}"
fi

if [ -n "$include_elements" ]; then
  command+=" -i ${include_elements}"
fi

if [ -n "$exclude_elements" ]; then
  command+=" -e ${exclude_elements}"
fi

if [ "$keep_token_tags" = "true" ]; then
  command+=" -kt"
fi

if [ "$keep_empty" = "true" ]; then
  command+=" -ke"
fi

if [ "$discard_freetext" = "true" ]; then
  command+=" -df"
fi

if [ "$no_glue" = "true" ]; then
  command+=" -ng"
fi

if [ -n "$glue" ]; then
  command+=" -g ${glue}"
fi

if [ "$fragment" = "true" ]; then
  command+=" -F"
fi

if [ "$no_flattening" = "true" ]; then
  command+=" -nf"
fi

command+=" > /veld/output/${out_conlluish_xml_file}"

echo "executing:"
echo "$command"
eval "$command"

