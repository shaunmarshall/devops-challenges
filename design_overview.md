# DevOps Challenge

**Author**: Shaun Marshall

## Design Overview

The Workflow will deploy (if `terraform_apply` is set to true) the terraform IaC in AWS. I have designed the infrastructure across 2 availability zones giving High Availability on the Web Server. The VMs will only be accessible via a Bastion Host. The VPC contains 2 private and 2 public subnets with the relevant routing tables, internet gateway, and NAT gateway – allowing the VMs to access external repositories and have the functionality to get updates, while remaining secure.

I have opted to use Ansible to set up the HTTP server and copy over an `index.html` file. I have structured the Ansible configuration to allow updating playbooks easily without the need to update the terraform code. Just add the playbook into the `ansible` directory and update the `import_playbooks.yml`.

The deployment will be secure and only allow access to IP addresses that are in the `allowed_ip_cidr` variable. The Github Actions workflow has a step in it to get the IP of the Runner and allow for the deployment to succeed. This allow list will allow SSH access to the Bastion Host and then onto the VMs. An additional layer of security has been applied using Web Application Firewall v2, using the same `allowed_ip_cidr` variable.

The deployment will create the SSH keys and upload them to AWS, add them to the VMs during deployment, as well as making them available as a workflow artifact. It will also create an SSH config file to simplify the proxy SSH via the Bastion Host.

The workflow will fail on any stage errors. If the workflow is successful, it will display the terraform outputs as the last step.

To access the web page, use the DNS value of the Application Load Balancer using the HTTP protocol.
