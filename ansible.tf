# This file contains the configuration for running Ansible playbooks on the EC2 instances.

resource "null_resource" "run-ansible" {
  count = length(aws_instance.app)

  depends_on = [
    aws_instance.app,
    aws_lb.app,
    aws_wafv2_web_acl_association.api_assoc  
  ]

  provisioner "local-exec" {
    command = "export ANSIBLE_HOST_KEY_CHECKING=False && chmod 400 ${local_file.private_key.filename} && ansible-playbook -i '${aws_instance.app[count.index].private_ip},' ./ansible/import_playbooks.yml --ssh-extra-args='-i ${local_file.private_key.filename} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand=\"ssh -W %h:%p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@${aws_instance.bastion.public_ip} -i ${local_file.private_key.filename} ec2-user@${aws_instance.app[count.index].private_ip}\"' --extra-vars 'ansible_ssh_user=ec2-user ec2_work_dir=/home/ec2-user/ansible aws_region=${var.aws_region}' --private-key ${local_file.private_key.filename}"
  }
}
