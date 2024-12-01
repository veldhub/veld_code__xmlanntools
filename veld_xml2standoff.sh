#!/bin/bash

# This script is a wrapper for the underlying xmlanntools script. It handles input and output files,
# respective to the VELD design, and also constructs a command from the VELD compose file, which is
# then executed.

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

# The underlying script produces output next to the input file, which clashes with VELD's design. So
# the output file is moved from the input folder to the respective output folder. In case that the
# chain veld actually maps the input and output folder to the same host path, the `mv` operation
# might crash; hence ignoring such crashes with `set +e` and `2> /dev/null`
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

