[workernodes]
%{ for worker in worker_nodes }
${worker.hostname} ansible_host=${worker.ip_address}
%{ endfor }

[vmnames]
%{ for vmname in vmnames }
${vmname.name}=${vmname.value}
%{ endfor }
