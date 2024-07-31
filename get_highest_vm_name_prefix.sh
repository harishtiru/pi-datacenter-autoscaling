#!/bin/bash

# Determine which file to use
if [[ -f "ansible/inventory.ini" ]]; then
  FILE="ansible/inventory.ini"
else
  FILE="ansible/inventory.ini.old"
fi

# Process the chosen file
highest_prefix=$(awk '
/^\[vmnames\]/ {
  # Print lines under [workernodes] and [vmnames] sections
  if (/^\[vmnames\]/) {
    print $0
    # Read the lines under the current section until the next section starts or the file ends
    while ((getline line) > 0 && line !~ /^\[/) {
      if (line != "") print line # Remove blank lines
    }
  }
}
' "$FILE" | cut -f 2 -d= | grep -v "vmnames" | tail -1 | grep -o '[a-zA-Z]*')
# Output the result in JSON format
echo "{ \"output\": \"$highest_prefix\" }"
