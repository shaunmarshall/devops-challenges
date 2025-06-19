#!/bin/bash
# Anly required for AWS EC2 
# to connect to kubectl
# AKS and EKS kubectl can be run when connecting to cluster via az / aws cli config mergs

deployment_tag="devops-challenge"
aws_region=eu-west-1
ec2_instance_user="ec2-user"
private_ssh_key="./Artifacts/${deployment_tag}-private_key.pem"


# change permission of ssh key 
chmod 400 ./${private_ssh_key}

#Get Names and IP for k8s nodes
# expand logic in script when adding Azure Deplyments to ymal pipeline


aws ec2 describe-instances \
--region ${aws_region} \
--filters "Name=tag:Deployment,Values=${deployment_tag}" "Name=instance-state-name,Values=running" \
--query "Reservations[].Instances[].{name: Tags[?Key=='Name'].Value[],ip: NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress[],PublicDNS: PublicDnsName}" | jq -c ".[]" > ./ip_info.json
 

# get list of deployed instanse names / ips 
NICLIST=$(cat ./ip_info.json  | jq -r 'select(.name!=["bastion_host"])' | jq -c )
bastion_dns=$(cat ./ip_info.json  | jq -r 'select(.name | contains(["bastion"])).PublicDNS')

##########################################
#get ip address of each vm
##########################################
echo $NICLIST | tr " " "\n" | while read VM
do 

	NAME=$(echo $VM | jq -r '.name[]')
	IP=$(echo $VM | jq -r '.ip[]')
echo "
Host $NAME
HostName $IP
	IdentityFile ./${private_ssh_key}
User ${ec2_instance_user} 
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null
ProxyCommand ssh -q -W %h:%p -i ./${private_ssh_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p 22 -A ${ec2_instance_user}@${bastion_dns} 
" >> ./Artifacts/${deployment_tag}_ssh_config
done

#remove payload json
rm ./ip_info.json
