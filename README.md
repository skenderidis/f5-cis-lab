
# F5 CIS Azure Lab . (Work in progress)

Create a Lab environment to test CIS use-cases


## Table of Contents

- [Introduction](#introduction)
- [Pre-requisites](#pre-requisites)
- [Installation](#installation)
- [Variables](#variables)


## Introduction

The purpose of this repository is to create a Lab environment on Azure that we will be able to demo CIS use cases.<br>
We will use Terraform to perform the following:
* F5 VPC
* 1xBIGIP (25Mbps PAYG - Best)
* K8s VPC
* 3x Ubuntu 18.04.2 (1xMaster and 2xNodes)
* VPC Peering, Security Groups, Public IPs, etc.
* Ansible Dynamic invetories

<img src="https://raw.githubusercontent.com/skenderidis/f5-cis-lab/main/images/cis-lab-1.png">

We will use Ansible to perform the following:
* Provision the F5 appliance with Declerative Onboarding.
* Configure Kubernetes on the 3 ubuntu VMs
* Configure Flannel between BIGIP and Ubuntu Nodes/Master
* Create Apps/Namespaces/NGINX/CIS on Kubernetes


## Pre-requisistes

- Terraform installed
- Ansible installed
- Programmatic Access for Azure 

> (to-do) will update the instructions on Programmatic access on Azure

## Installation

Use git pull to make a local copy of the github repo.
```shell
git clone https://github.com/skenderidis/f5-cis-lab.git
```

In order for the terraform scripts to work it will require the following variables. 

| Variables          | Default  |
|--------------------|-------------------------------|
| subscription_id	   |  The subscription ID for Azure Authentication  |
| client_id	         |  The client ID for Azure Authentication    |
| client_secret      | 	The client secret for Azure Authentication |
| tenant_id          |  The Tenant ID for Azure Authentication  | 
| username	         |  The username that will be used for F5/Linux devices. Note: Do not use "admin"      |
| password	         |  The password that will be used for F5/Linux devices. Note: avoid using special characters like `'"^{}\/?><`       |
| location	         |  The location that the lab will be deployed (like eastus)  |
| rg_prefix	         |  The prefix for resource groups that will be created   |


It is recommended to use Environment variables to set the above TF variables. Run the commands below (modify them first with the correct values).
```shell
export TF_VAR_subscription_id=YOUR_SUBSCRIPTION_ID
export TF_VAR_client_id=YOUR_CLIENT_ID
export TF_VAR_client_secret=YOUR_CLIENT_SECRET
export TF_VAR_tenant_id=YOUR_TENANT_ID
export TF_VAR_username=YOUR_USERNAME
export TF_VAR_password=YOUR_PASSWORD
export TF_VAR_location=YOUR_LOCATION
export TF_VAR_rg_prefix=YOUR_LOCATION
```


Once the Environment variables have been set navigate to `f5-cis-lab` directory. Run the `deploy.sh` script to create the entire environment Terraform.
```shell
cd f5-cis-lab/
./deploy.sh
```


The Bash script is shown below

```shell
#!/usr/bin/env bash
# Filename: deploy.sh

cd tf/azure/f5_standalone
terraform init
terraform apply --auto-approve

cd ../k8s
terraform init
terraform apply --auto-approve

cd ../peering/
terraform init
terraform apply --auto-approve

cd ../../ansible
ansible-playbook create-inventories.yml
ansible-playbook setup-k8s.yml -i k8s-inventory.ini
ansible-playbook setup-flannel.yml -i k8s-inventory.ini
ansible-playbook deploy-nginx-cis.yml -i k8s-inventory.ini

######################################################################################### 
###                 Only if you have the DNS zone deployed in Azure.                  ###
###     You will need to define the Resource Group and Zone name on the variables.tf  ###
######################################################################################### 
#cd terraform/azure/dns/k8s
#terraform init
#terraform apply --auto-approve

#cd terraform/azure/dns/f5-standalone
#terraform init
#terraform apply --auto-approve
######################################################################################### 



```


### Variables

Most of the variables can be found on `variables.tf` on the `tf` directories. Please see below the example on the `f5_standalone` directory.

```shell

######### Azure authentication variables #########

variable subscription_id      {}
variable client_id            {}
variable client_secret        {}
variable tenant_id            {}


#########   Common Variables   ##########
variable tag        {default = "CIS - Kubernetes Demo"}
variable password	      {}
variable username		  	    	{}
variable location				      {}
variable rg_prefix			    	{}

###########   F5  Variables   ############
variable f5_rg_name				    {default = "bigip-rg" }
variable f5_vnet_name  			  {default = "secure_vnet"}
variable f5_vnet_cidr  			  {default = "10.1.0.0/16" }

variable mgmt_subnet_name		  {default = "management"}
variable int_subnet_name  		{default = "internal"}
variable ext_subnet_name  		{default = "external" }

variable mgmt_subnet_cidr		  {default = "10.1.1.0/24" }
variable int_subnet_cidr  		{default = "10.1.20.0/24" }
variable ext_subnet_cidr  		{default = "10.1.10.0/24" }

variable self_ip_mgmt_01  		{default = "10.1.1.4"}
variable self_ip_ext_01  		  {default = "10.1.10.4"}
variable add_ip_ext_01_1  		{default = "10.1.10.10"}
variable add_ip_ext_01_2  		{default = "10.1.10.20"}
variable add_ip_ext_01_3  		{default = "10.1.10.30"}
variable self_ip_int_01  		  {default = "10.1.20.4"}
variable prefix_bigip  			  {default = "bigip1"}

variable allowedIPs				    {default = ["0.0.0.0/0"]}


########################
#  F5 Image related	   #
########################

variable f5_version 			    {default = "15.1.201000"}
variable f5_image_name 			  {default = "f5-bigip-virtual-edition-25m-best-hourly" }
variable f5_product_name 		  {default = "f5-big-ip-best"}
variable f5_instance_type 		{default = "Standard_DS4_v2"}
variable do_url 				      {default = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.21.0/f5-declarative-onboarding-1.21.0-3.noarch.rpm"}
variable as3_url      {default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.28.0/f5-appsvcs-3.28.0-3.noarch.rpm"}
variable ts_url       {default = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.20.0/f5-telemetry-1.20.0-3.noarch.rpm" }
variable cfe_url      {default = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.8.0/f5-cloud-failover-1.8.0-0.noarch.rpm" }
variable fast_url     {default = "https://github.com/F5Networks/f5-appsvcs-templates/releases/download/v1.9.0/f5-appsvcs-templates-1.9.0-1.noarch.rpm" }

```



