## Create and Configure GCP VPC By Terraform
This Terraform configuration creates VPC(Virtual Private Cloud network), firewall rules and VM instance with two subnetworks in Google Cloud Platform. 

Prerequisites:  
Google Cloud Platform (GCP) account
GCloud CLI
Terraform

VPC Configuration:  
VPC Network: regional routing 
Subnets: webapp and db
Internet Gateway Route: default internet gateway

Terraform command:  
terraform init  
terraform plan  
terraform apply
