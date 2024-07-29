#!/bin/bash

# Get the highest VM name prefix
highest_vm_prefix=$(awk -F'=' '/worker[0-9]+_name=/ {gsub("[^[:alpha:]]", "", $2); print $2}' ansible/inventory.ini.old | sort -n | tail -1)

# Output JSON format
echo "{ \"output\": \"$highest_vm_prefix\" }"
