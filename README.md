# terraformproject
# AWS Infrastructure as Code (IaC) Deployment
This repository contains the configuration and templates to deploy the specified AWS infrastructure using the Infrastructure as Code (IaC), Terraform.
## Prerequisites
Before you begin, ensure you have the following prerequisites in place:
- An AWS account with the necessary permissions to create resources.
- An IAM EC2 Role for your EC2 instances.
- The IaC tool to use Terraform installed on your local machine.
- The AWS CLI configured with the appropriate access and secret keys.
## Deployment Instructions
Step 1: Clone this Repository
git clone https://github.com/annick2018/terraformproject.git
Create a directory
Create a git branch
Step 2: Configure Your IaC Tool
Edit the configuration files for the terraform.tf to set the necessary AWS credentials and region.
Step 3: Run the Deployment
Execute the IaC tool command to create the AWS resources using the provided configuration files.
# Example using Terraform
terraform init
terraform plan
terraform apply
Step 4: Access Your Resources
Once the deployment is complete, you will have the following resources set up in your AWS environment:
-EC2 instances in each of the private subnets.
-Firewall rules to allow communication between EC2 instances over port range 4001-4003.
-EBS volumes attached to each EC2 instance.
-IAM Role attached to each EC2 instance.
-An internal Elastic Load Balancer for accessing the EC2 instances on port 443. The EC2 instances are part of a Target Group.
-EC2 instances are set up in an Autoscaling Group to ensure high availability and automatic replacement of failed instances.
-Spot instances are configured for use with the EC2 instances.
#Cleanup
To clean up and destroy the resources created, use the appropriate command for your IaC tool:
Terraform destroy
