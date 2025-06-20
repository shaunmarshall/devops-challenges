
# DevOps Challenge

## Objective

### Infrastructure as Code (IaC)

Choose either AWS or Azure.
Using an Infrastructure as Code tool of your choice, define the necessary code
to create a basic compute instance (e.g., a virtual machine or equivalent
lightweight service) that would serve a simple static webpage (e.g., an
index.html file). Include the configuration for making the instance publicly
accessible on port 80 via the appropriate network security configuration for
your chosen cloud. Do not deploy this infrastructure.

- **Check out code (this task description and your IaC configuration).**
- **Include a placeholder step or command that would execute the deployment of your defined infrastructure using your chosen IaC tool.**
- **Clearly indicate what command or process would be used in a real deployment scenario.**
- **Include a basic step to indicate the potential success or failure of the infrastructure deployment (even though it won't be actually run).**

---

## Instructions

- I Have opted to deploy to AWS 
- I have opted to use Terraform and Ansible as my IaC choice
- Using GitHub Actions Workflow to deploy the AWS Infrastructure
- **Infrastructure code will only deploy if env `terraform_apply` is set to true**

## Manual Steps to deploy
### Step 1: Clone the Repository

To get started, clone the repository to your local machine:

```bash
git clone git@github.com:shaunmarshall/terraform-api-gateway.git
cd devops-challenge
```

### Step 2: Configure AWS Credentials

By default, the Terraform configuration will use the AWS API keys stored in the following file:

```
$HOME/.aws/credentials
```

Alternatively, you can manually add your `access_key` and `secret_key` to the `provider.tf` file.

---

### Step 3: Update Varaibles files

- **Add Your Public IP address in CIDR format (1.2.3.4/32) to the `allowed_ips` variable**
- **Add IP addresses to `allowed_ip_cidrs` varaible**
- Update `aws_region` variable to own prefered region
- Change `private_subnet_cidrs`, `public_subnet_cidrs` and `vpc_cidr` if required

**Note: the workflow will dynamicly add the runner IP address to allow the set up of Ansible on the virtual Machines**
---


### Step 4: Initialize Terraform

Run the following command to initialize the Terraform environment:

```bash
terraform init
```

### Step 5: Apply the Terraform Configuration

To deploy the infrastructure, apply the Terraform code with the following command:
**Note:  the workflow has a condition if false wont apply the terraform code.**

```bash
terraform apply --auto-approve
```

This will automatically approve the changes and apply them to your AWS environment.

---

## Accessing the Web Page

Terraform will output the DNS name value of the Application Load Balancer.
Navigate to that URL using `http://` protocal


---
