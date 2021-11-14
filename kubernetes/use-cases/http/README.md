
# F5 CIS Azure Lab (Work in progress)

Create a Lab environment in Azure to test several CIS use-cases


## Table of Contents

- [Introduction](#introduction)
- [Pre-requisites](#pre-requisites)
- [Installation](#installation)
- [Use-cases](#use-cases)
- [Variables](#variables)


## Introduction

The purpose of this repository is to create a Lab environment on Azure that we will be able to demo [CIS use-cases](#use-cases).<br>

We will use Terraform to create the following:
* F5 VPC
* 1xBIGIP (25Mbps PAYG - Best)
* K8s VPC
* 3x Ubuntu 18.04.2 (1xMaster and 2xNodes)
* VPC Peering, Security Groups, Public IPs, etc.
* Ansible Dynamic inventories

<img src="https://raw.githubusercontent.com/skenderidis/f5-cis-lab/main/images/cis-lab-1.png">

We will use Ansible to configure the following:
* Provision the F5 appliance with Declerative Onboarding.
* Configure Kubernetes on the 3 ubuntu VMs
* Configure Flannel between BIGIP and Ubuntu Nodes/Master
* Create Apps/Namespaces/NGINX/CIS on Kubernetes


## Pre-requisistes

- Terraform installed
- Ansible installed
- Programmatic Access for Azure 

> (to-do) **** Need to update the instructions on Programmatic access for Azure ****

## Installation

Use git to make a local copy of the github repo.
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


There are multiple ways of inputing the above TF variables, but it is recommended to use Environment variables. Navigate to `f5-cis-lab` directory and open the `export_vars` file.

```shell
cd f5-cis-lab/
sudo nano export_vars
```

The contents of the `export_vars` file are shown below
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

Fill in the right information for the variables and then paste them on the terminal 


Once the Environment variables have been set run the `deploy.sh` script to create and configure the entire environment with Terraform and Ansible.
```shell
cd f5-cis-lab/
./deploy.sh
```


The `deploy.sh` script is shown below

```shell
#!/usr/bin/env bash
# Filename: deploy.sh

cd tf/f5_standalone
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
ansible-playbook do-standalone.yml -i k8s-inventory.ini
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


### Use-cases
Throughout this demo we will try to demo as many use cases as possible with the use of CRDs, ConfigMaps and Ingress.
CRD use cases:

1) Publish two HTTP applications with CRD Virtual Server <a href="https://github.com/skenderidis/f5-cis-lab/tree/main/use-cases/crd/http">info </a>
2) Publish two HTTPS applications with CRD Virtual Server and TLSProfile <a href="https://github.com/skenderidis/f5-cis-lab/tree/main/use-cases/crd/ssl">info </a>
3) Publish and protect with WAF one HTTP Application 
4) Publish and protect with L7 DDOS one HTTP Application 
5) Publish and protect with APM one HTTP Application
6) Publish and protect with AFM one HTTP Application
7) Publish one HTTP Application and configure High Speed Logging for HTTP logs 
8) Publish one HTTP Application and configure Caching/Compression/OneConnect

The CRD/IPAM use cases:
1) Publish three HTTP applications with CRD Virtual Server & IPAM Controller 
2) Type Load Balancer
3) Multi-service Type Load Balancer

The NGINX-CIS use cases:
1) Publish 5 applications with NGINX Ingress Controller and use CIS to publish NGINX with Layer 4 CRD (maintaining clientIP visibility) 
2) Publish 5 applications with NGINX Ingress Controller and use CIS to publish NGINX with Layer 7 CRD and different WAF policy per application
3) Publish 5 applications with NGINX Ingress Controller and use CIS to publish NGINX with Layer 7 CRD and protected with AFM

ConfigMap and Ingress use cases:

