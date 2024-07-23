hostnames=[]
hostnames=$(awk 'NF==2{print $1}' ansible/inventory.ini)
ipaddress=[]
ipaddress=$(awk 'NF==2{print $2}' ansible/inventory.ini|cut -f 2 -d=)
vmnames=[]
vmnames=$(grep 'worker[0-9]_name=' ansible/inventory.ini |  awk -F= '{print $2}')
for hostname, ipaddr, vmname in zip(hostnames, ipaddress, vmnames):
do
  print(f"hostname={hostname}, ipaddress={ipaddr}, vmnames={vmname}")
done

