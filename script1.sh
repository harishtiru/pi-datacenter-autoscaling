#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <inventory_file>"
    exit 1
fi

inventory_file="$1"
# Initialize arrays
hostnames=()
ipaddresses=()
vmnames=()

# Extract data from inventory file
while IFS= read -r line; do
    if [[ $(echo "$line" | awk 'NF==2') ]]; then
        hostnames+=($(echo "$line" | awk '{print $1}'))
        ipaddresses+=($(echo "$line" | awk '{print $2}' | cut -f 2 -d=))
    fi
done < "$inventory_file"

while IFS= read -r line; do
    if [[ $line == worker[0-9]_name=* ]]; then
        vmnames+=($(echo "$line" | awk -F= '{print $2}'))
    fi
done < "$inventory_file"

# Loop through arrays and print
for i in "${!hostnames[@]}"; do
    hostname="${hostnames[$i]}"
    ipaddr="${ipaddresses[$i]}"
    vmname="${vmnames[$i]}"
    echo "hostname=${hostname}, ipaddress=${ipaddr}, vmname=${vmname}"
done
