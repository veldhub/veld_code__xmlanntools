#!/bin/bash

set -e

in_json_file_expected="${in_txt_file%.txt}.json"
if [ -n "$in_json_file" ] && [ $in_json_file != $in_json_file_expected ]; then
  cp /veld/input/"$in_json_file" /veld/input/"$in_json_file_expected"
  rm_json_file=1
fi

in_ann_json_file_expected="${in_txt_file%.txt}.ann.json"
if [ -n "$in_ann_json_file" ] && [ $in_ann_json_file != $in_ann_json_file_expected ]; then
  cp /veld/input/"$in_ann_json_file" /veld/input/"$in_ann_json_file_expected"
  rm_ann_json_file=1
fi

command="./standoff2xml /veld/input/${in_txt_file}"

if [ "$token_annotation" = "true" ]; then
  command+=" -t"
fi

if [ -n "$warn_breaking" ]; then
  command+=" -Wb ${warn_breaking}"
fi

if [ -n "$token_element" ]; then
  command+=" -te ${token_element}"
fi

if [ -n "$sentence_element" ]; then
  command+=" -se ${sentence_element}"
fi

if [ "$keep_between_sentences" = "true" ]; then
  command+=" -kb"
fi

echo "executing:"
echo "$command"
eval "$command"

if [ "$rm_json_file" = "1" ]; then
  rm /veld/input/"$in_json_file_expected"
fi

if [ "$rm_ann_json_file" = "1" ]; then
  rm /veld/input/"$in_ann_json_file_expected"
fi

set +e
out_ann_xml_file_generated="${in_txt_file%.txt}.ann.xml"
if [ -n "$out_ann_xml_file" ]; then
  mv /veld/input/"$out_ann_xml_file_generated" /veld/output/"$out_ann_xml_file" 2> /dev/null
else
  mv /veld/input/"$out_ann_xml_file_generated" /veld/output/ 2> /dev/null
fi
exit 0

