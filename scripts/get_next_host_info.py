import sys
import json
import re

def get_next_host_info(inventory_path, selected_host_file_content):
    selected_host = selected_host_file_content.strip()

    with open(inventory_path, 'r') as f:
        content = f.read()

    # Extract the last worker vmname, IP address, and VM name
    vmnames = re.findall(r'worker\d+_name=([^\s]+)', content)
    ip_addresses = re.findall(r'ansible_host=(\d+\.\d+\.\d+\.\d+)', content)
    vm_names = re.findall(r'worker\d+', content)

    if not vmnames or not ip_addresses or not vm_names:
        raise ValueError("No valid vmnames, IP addresses, or VM names found in inventory.ini")

    last_vmname = sorted(vmnames)[-1]
    last_ip = sorted(ip_addresses, key=lambda ip: list(map(int, ip.split('.'))))[-1]
    last_vm_name = sorted(vm_names)[-1]

    last_vmname_index = int(re.search(r'\d+', last_vmname).group())
    last_ip_index = int(last_ip.split('.')[-1])
    last_vm_name_index = int(re.search(r'\d+', last_vm_name).group())

    next_vmname_index = last_vmname_index + 1
    next_ip_index = last_ip_index + 1
    next_vm_name_index = last_vm_name_index + 1

    next_vmname_prefix = "vmname"
    next_vm_hostname_prefix = "worker"

    result = {
        "next_vmname_index": next_vmname_index,
        "next_ip_index": next_ip_index,
        "next_vm_name_index": next_vm_name_index,
        "vmname_prefix": next_vmname_prefix,
        "vm_hostname_prefix": next_vm_hostname_prefix,
        "selected_host": selected_host
    }

    return result

if __name__ == "__main__":
    input = json.loads(sys.stdin.read())
    inventory_path = input['inventory_path']
    selected_host_file_content = input['selected_host_file_content']

    result = get_next_host_info(inventory_path, selected_host_file_content)
    print(json.dumps({"result": result}))

