#!/bin/bash

# Get the highest IP suffix
highest_suffix=$(awk 'NF==2{print $2}' ansible/inventory.ini | cut -f 2 -d= | awk -F'.' '{print $4}' | sort -n | tail -1)

# Output JSON format
echo "{ \"output\": \"$highest_suffix\" }"
