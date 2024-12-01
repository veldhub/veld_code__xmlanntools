#!/bin/bash

# This script is a wrapper for the underlying xmlanntools script. It handles input and output files,
# respective to the VELD design, and also constructs a command from the VELD compose file, which is
# then executed.

set -e

# because the script excpects additional files with specific naming, but the code veld enables more
# flexibility, a temporary input file is created for consumption of the underlying script, without
# modifying that.
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

# The underlying script produces output next to the input file, which clashes with VELD's design. So
# the output file is moved from the input folder to the respective output folder. In case that the
# chain veld actually maps the input and output folder to the same host path, the `mv` operation
# might crash; hence ignoring such crashes with `set +e` and `2> /dev/null`
set +e
out_ann_xml_file_generated="${in_txt_file%.txt}.ann.xml"
if [ -n "$out_ann_xml_file" ]; then
  mv /veld/input/"$out_ann_xml_file_generated" /veld/output/"$out_ann_xml_file" 2> /dev/null
else
  mv /veld/input/"$out_ann_xml_file_generated" /veld/output/ 2> /dev/null
fi

exit 0

