#!/bin/bash

# Define the input file
input_file="ansible/inventory.ini"

# Find the highest IP address using awk
highest_ip=$(awk '
/^\[workernodes\]/, /^\[/{ 
    if ($2 ~ /^ansible_host=/) {
        split($2, a, "=");
        ip = a[2];
        split(ip, octets, ".");
        if (!max_ip) {
            max_ip = ip;
            max_octets = octets;
        } else {
            for (i = 1; i <= 4; i++) {
                if (octets[i] > max_octets[i]) {
                    max_ip = ip;
                    max_octets = octets;
                    break;
                } else if (octets[i] < max_octets[i]) {
                    break;
                }
            }
        }
    }
}
END {
    print max_ip;
}
' "$input_file")

echo "The highest IP address is: $highest_ip"

