#!/bin/bash
awk -F'=' '/worker[0-9]+_name=/ {gsub("[^[:alpha:]]", "", $2); print $2}' ansible/inventory.ini | sort -n | tail -1
