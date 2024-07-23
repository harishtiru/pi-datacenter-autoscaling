#!/bin/bash
awk 'NF==2{print $1}' ansible/inventory.ini | grep -o '[a-zA-Z]*' | tail -1
