# CISCO ASAv on AWS

## Configure amazon
####VPC
Create the network (VPC) where you want to work in  
**Name Tag** -> Name of your VPC (My-VPC)  
**CIDR block** -> Size of your network (10.0.0.0/16)  
Remember to assign a internet gateway to this VPC.

#### Route table
Create a new route table:  
10.0.0.0/16 local  
0.0.0.0/0 igw (internet gateway)

#### Network ACL 
Create one and allow everything:   
**Rule** Number  
**Type** All Traffic  
**Protocol** ALL   
**Port Range** ALL  
**source** 0.0.0.0/0  
**Allow/Deny** ALLOW  

#### Subnet
SUB-APP (inside network) (10.0.100.0/24)  
SUB-WEB (outside network) (10.0.200.0/24)  
SUB-MGT (management network) (10.0.250.0/24)  

## Install the AMI CISCO ASAv Image
Go to the instance and then LAUNCH INSTANCE.  
Seatch for the CISCO ASAv in the AWS Marketplace  

### Things to change
**Network** : Put the VPC that you have create previously
**subnet** : Select the SUB-MGT  
**Click on advanced details** and copy paste the config.cisco file on it. THIS IS THE MOST IMPORTANT THING
**Security Group** Just put the one created before



