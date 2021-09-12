
# F5 CIS with EKS. (Work in progress)

Providing Ingress Services for EKS with F5 CIS (in HA configuration) 



## Table of Contents



- [Introduction](#introduction)
- [Pre-requisites](#pre-requisites)
- [Installation](#installation)
- [Variables](#variables)
- [Support](#support)

## Introduction

This repository is split into two demos that show different use cases on how CIS can be used to publish ingress services for EKS.<br>
In first demo the clients will be connecting through the internet to the public IPs that are created on the BIGIP and BIGIP will SNAT the client IP when it sends the connection back to EKS.<br>
With the use of a Terraform script we will deploy the following infrastructure in AWS:
* Main VPC with 6 subnets
* EKS with 2 nodes
* 2xBIGIP devices in HA configuration (PAYG License)
* Routes, ENIs, EIPs, Security Groups, IGW, NAT Gateways, etc
* Initial configuration of F5 devices with DO and CFE 

[![Network Diagram](https://github.com/skenderidis/f5-eks-demo/blob/main/images/F5-EKS-demo1.png?raw=true)]()

In the second demo the clients will be connecting through another VPC and BIGIP will NOT change the source IP address. To achieve symmetric traffic between F5 and EKS, we have configured a route on the EKS subnet to send the client's VPC traffic through the BIGIP devices.<br>
With the use of a Terraform script we will deploy the following infrastructure in AWS:
* Main VPC with 6 subnets
* Client VPC with 1 subnet
* EKS with 2 nodes
* 2xBIGIP devices in HA configuration (PAYG License)
* Test PC on client VPC  *********  Not Yet Implemented    *************
* Routes, ENIs, EIPs, Security Groups, IGW, NAT Gateways, etc
* Initial configuration of F5 devices with DO and CFE 

[![Network Diagram](https://github.com/skenderidis/f5-eks-demo/blob/main/images/F5-EKS-demo2.png?raw=true)]()

> In both demos CFE and DO will be deployed with `run-time init` during the terraform deployment of the F5 devices.

Some of the ingress services that will be deployed during this demo are:
* Virtual Server CRDs (Layer 7) to publish an web appplication that runs on EKS
* Transport Server CRDs (Layer 4) to publish a TCP appplication that runs on EKS
* Transport Server CRDs (Layer 4) to publish a UDP appplication that runs on EKS
* ConfigMap tp publish a STCP appplication that runs on EKS.

The full list of ingress serfvices can be found on the directory Demo-*/kube/ingress.


## Pre-requisistes

- Terraform installed
- AWS credentials for programmatic access
- For the demo we are using a PAYG License of BIGIP 200 Best Bundle. In order for Terraform to able to deploy this instance you would need to "Accept Terms" on the AWS Marketplace. 
Go to "AWS Marketplace subscriptions" page and select “Discover products” from the left column. Then type “BIGIP 200Mbps Best” in the search box. Select the BIGIP 200Mbps => “Continue to Subscribe” => “Accept Terms”
> This might take some time to be approved


## Installation

Use git pull to make a local copy of the Terraform code.
```shell
git clone https://github.com/dudesweet/f5_terraform.git
```

Navigate to directory "Demo-1" or "Demo-2" depending on your requirements. For this example we will navigate to Demo-1 directory
```shell
cd f5-eks-demo/Demo-1
```
Run the following command to initialize Terraform
```shell
terraform init 
```

Run the command `terraform plan` to see the changes that are going to be made.
```shell
terraform plan 
```

To build the Lab infrastructure run the command `terraform apply`.
```shell
terraform apply
```
> "terraform apply" will prompt you with a yes/no to confirm if you want to go ahead and make the changes.



### Variables

Most of the variables can be found on variables.tf under Demo-1 or Demo-2 directories

```shell
variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable f5_username {
  description = "The admin username of the F5 Bigip that will be deployed"
  type        = string
  default     = "bigipuser"
}

variable f5_password {
  description = "Password of the F5 Bigip that will be deployed"
  default     = "Bigip123"
}

variable f5_ami_search_name {
  description = "BIG-IP AMI name to search for"
  type        = string
  default     = "F5 BIGIP-16* PAYG-Best 200Mbps*"
}

variable ec2_instance_type {
  description = "AWS EC2 instance type"
  type        = string
  default     = "m5.xlarge"
}

## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable DO_URL {
  description = "URL to download the BIG-IP Declarative Onboarding module"
  type        = string
  default     = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.21.0/f5-declarative-onboarding-1.21.0-3.noarch.rpm"
}
## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable AS3_URL {
  description = "URL to download the BIG-IP Application Service Extension 3 (AS3) module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.28.0/f5-appsvcs-3.28.0-3.noarch.rpm"
}

## Please check and update the latest TS URL from https://github.com/F5Networks/f5-telemetry-streaming/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable TS_URL {
  description = "URL to download the BIG-IP Telemetry Streaming module"
  type        = string
  default     = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.20.0/f5-telemetry-1.20.0-3.noarch.rpm"
}

## Please check and update the latest Failover Extension URL from https://github.com/f5devcentral/f5-cloud-failover-extension/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable CFE_URL {
  description = "URL to download the BIG-IP Cloud Failover Extension module"
  type        = string
  default     = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.8.0/f5-cloud-failover-1.8.0-0.noarch.rpm"
}

## Please check and update the latest FAST URL from https://github.com/F5Networks/f5-appsvcs-templates/releases/latest 
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable FAST_URL {
  description = "URL to download the BIG-IP FAST module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-templates/releases/download/v1.9.0/f5-appsvcs-templates-1.9.0-1.noarch.rpm"
}
## Please check and update the latest runtime init URL from https://github.com/F5Networks/f5-bigip-runtime-init/releases/latest
# always point to a specific version in order to avoid inadvertent configuration inconsistency
variable INIT_URL {
  description = "URL to download the BIG-IP runtime init"
  type        = string
  default     = "https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.2.1/dist/f5-bigip-runtime-init-1.2.1-1.gz.run"
}

```


### Declerative Onboarding (DO)

DO declaration will run during the `runtime init` process. The Declaration can be found on the folder `modules => bigip => f5_onboard.tmpl`


```shell
        schemaVersion: 1.0.0
        class: Device
        async: true
        label: Onboard BIG-IP
        Common:
          class: Tenant
          mySystem:
            class: System
            hostname: ${hostname}
          myDns:
            class: DNS
            nameServers:
              - 8.8.8.8
              - 169.254.169.253
            search:
              - f5.com
          admin:
            class: User
            userType: regular
            password: ${bigip_password}
            shell: bash
          myNtp:
            class: NTP
            servers:
              - 169.254.169.123
            timezone: UTC
          external:
            class: VLAN
            tag: 4093
            mtu: 1500
            interfaces:
              - name: '1.1'
                tagged: false
            cmpHash: dst-ip
          external-selfip:
            class: SelfIp
            address: ${self-ip-ext}/24
            vlan: external
            allowService: none
            trafficGroup: traffic-group-local-only
          default:
            class: Route
            gw: ${gateway}
            network: default
            mtu: 1500
          servers-route:
            class: Route
            gw: ${gateway_servers}
            network: 10.0.0.0/16
            mtu: 1500
          internal:
            class: VLAN
            tag: 4094
            mtu: 1500
            interfaces:
              - name: '1.2'
                tagged: false
            cmpHash: dst-ip
          internal-selfip:
            class: SelfIp
            address: ${self-ip-int}/24
            vlan: internal
            allowService: default
            trafficGroup: traffic-group-local-only
          configsync:
            class: ConfigSync
            configsyncIp: "/Common/internal-selfip/address"
          failoverAddress:
            class: FailoverUnicast
            address: "/Common/internal-selfip/address"
          failoverGroup:
            class: DeviceGroup
            type: sync-failover
            members:
            - ${self-ip-int}
            - ${ha_remote_f5}
            owner: ${ha_primary_f5}
            autoSync: false
            saveOnAutoSync: false
            networkFailover: true
            fullLoadOnSync: false
            asmSync: false
          trust:
            class: DeviceTrust
            localUsername: admin
            localPassword: ${bigip_password}
            remoteHost: ${ha_remote_f5}
            remoteUsername: admin
            remotePassword: ${bigip_password}

```


### Variables

Most of the variables can be found on variables.tf under Demo-1 or Demo-2 directories




The most common variables that you might want to chage are:


These BIG-IP versions are supported in these Terraform versions.

| Variables       | Default |	Terraform 0.13  |	Terraform 0.12  | Terraform 0.11  |
|-----------------|---------------|-----------------|-----------------|-----------------|
| BIG-IP 16.x	    |      X        |       X         |       X         |      X          |
| BIG-IP 15.x	    |      X        |       X         |       X         |      X          |
| BIG-IP 14.x	    | 	   X        |       X         |       X         |      X          |
| BIG-IP 12.x	    |      X        |      	X         |       X         |      X          | 
| BIG-IP 13.x	    |      X        |       X         |       X         |      X          |



## Support


