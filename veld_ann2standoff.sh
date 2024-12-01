#!/bin/bash

# This script is a wrapper for the underlying xmlanntools script. It handles input and output files,
# respective to the VELD design, and also constructs a command from the VELD compose file, which is
# then executed.

set -e

# because the script excpects additional files with specific naming, but the code veld enables more
# flexibility, a temporary input file is created for consumption of the underlying script, without
# modifying that.
in_txt_file_expected="${in_conllu_file%.conllu}.txt"
if [ -n "$in_txt_file" ] && [ $in_txt_file != $in_txt_file_expected ]; then
  cp /veld/input/data/"$in_txt_file" /veld/input/data/"$in_txt_file_expected"
  rm_txt_file=1
fi

command="./ann2standoff /veld/input/data/${in_conllu_file}"

if [ -n "$in_ann2standoff_ini_file" ]; then
  command+=" -c /veld/input/config/${in_ann2standoff_ini_file}"
fi

if [ -n "$profile_name" ]; then
  command+=" -p ${profile_name}"
fi

echo "executing:"
echo "$command"
eval "$command"

if [ "$rm_txt_file" = "1" ]; then
  rm /veld/input/data/"$in_txt_file_expected"
fi

# The underlying script produces output next to the input file, which clashes with VELD's design. So
# the output file is moved from the input folder to the respective output folder. In case that the
# chain veld actually maps the input and output folder to the same host path, the `mv` operation
# might crash; hence ignoring such crashes with `set +e` and `2> /dev/null`
set +e
out_json_file_generated="${in_conllu_file%.conllu}.ann.json"
if [ -n "$out_json_file" ]; then
  mv /veld/input/data/"$out_json_file_generated" /veld/output/"$out_json_file" 2> /dev/null
else
  mv /veld/input/data/"$out_json_file_generated" /veld/output/ 2> /dev/null
fi

exit 0

