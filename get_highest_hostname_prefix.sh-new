#!/bin/bash

# Determine which file to use
if [[ -f "ansible/inventory.ini" ]]; then
  FILE="ansible/inventory.ini"
else
  FILE="ansible/inventory.ini.old"
fi

# Process the chosen file
highest_prefix=$(awk '
/^\[workernodes\]/ {
  # Print lines under [workernodes] and [vmnames] sections
  if (/^\[workernodes\]/) {
    print $0
    # Read the lines under the current section until the next section starts or the file ends
    while ((getline line) > 0 && line !~ /^\[/) {
	    if (line != "") print line # Remove blank lines
    }
  }
}' "$FILE" | awk 'NF==2{print $1}'|tail -1| grep -o '[a-zA-Z]*')
# Output the result in JSON format
echo "{ \"output\": \"$highest_prefix\" }"
