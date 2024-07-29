[master]
kubehost125 ansible_host=172.28.8.125

[all:vars]
ansible_ssh_private_key_file=${idrsa}
ansible_user=test
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
