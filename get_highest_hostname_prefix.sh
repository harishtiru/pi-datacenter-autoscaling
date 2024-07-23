#!/bin/bash

# Get the highest hostname prefix
highest_prefix=$(awk 'NF==2{print $1}' ansible/inventory.ini | grep -o '[a-zA-Z]*' | tail -1)

# Output JSON format
echo "{ \"output\": \"$highest_prefix\" }"
