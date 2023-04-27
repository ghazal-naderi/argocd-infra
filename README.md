# argocd-infra

# App of Apps Parent App repo

## What is AMI bakery?
The AMI Bakery repository provides the foundations for configuring, building and distributing Amazon Machine Images (AMIs) to be used within the Contino AWS Account.

A base image is first created. Any subsequent images must be built using this base image as the source. Once a new AMI is built and approved it is deployed to Contino AWS Dev Account

## AMI Build Design

![arch](assets/AMI-bakery-steps.svg)

## How to use this repository 
- Clone this using SSH : ```git@github.com:contino/ami-bakery.git```


# Prerequisites 
GitHub runner needs to have below tools installed 

* `packer`
* `ansible`
* `Git`
* `jq`

## Tools In Use
* [Packer](https://packer.io) - Orchestration of the automated creation of machine images.
* [Ansible](https://ansible.com) - Configuration management of the images to be built.
* [Make](https://www.gnu.org/software/make/manual/make.html) - Run and compile your programs more efficiently

## Images
The *rhel9.0* image uses Red Hat Enterprise Linux (RHEL) 90 as its source. 
All other images are built from this base image


## Building A New Image
To create a new image, you can use the skeleton provided in `bakery/images/example-ami`. Just copy this  folder and paste it under `bakery/images`. Change the name of your AMI and then change each of the following files as required:
* `ansible/playbook.yml` - this file contains ansible config code to provison software/apps on top of source (base) image
* `packer-variables.json` - this file contains packer variables for image being build (e.g. source/base image information, name and tag of ami being created)

### Packer Configuration
A single global `ami-bakery.pkr.hcl` file is used for all builds, and is parameterised with variables per image. See `bakery/images/<name>/packer-variables.json`.

**Useful Information** 
`global-packer-variables.pkrvars.hcl` contains global parameters for packer such as VPC/Subnet ID/AWS region where temp EC2 instance will be provisioned. Note that these ids should correspond to a valid VPC and a public subnet within it. Otherwise, packer builder will be unable to SSH to temp EC2 instance.


### Ansible Playbook
Ansible is used as a provisioner to configure the image. The Ansible playbook used to define roles and variables to use for a new image is `bakery/images/<ami-name>/ansible/playbook.yml`. Any roles used should be from Ansible Galaxy

### Choosing An Image To Build
The AMI Bakery uses a script `scripts/ami-to-build.sh` to determine which image(s) it should build when pushing to the remote. This script works by reading the git commit history and finding which files changed in the previous commit - it then finds which AMI folder these files belong to, in order to determine the image name.
If no AMI files have changed, it will build `rhel9.0-base` by default. Otherwise it will build any AMIs that have changed.
Any AMIs that have changed will be built in parallel.

### Security Scanning
Trivy is used ro AMIs security scanning, when the image has completed building packer creates the `<ami-name>-manifest.json` and the ami-id is extracted form the file with use of `scan.sh`
This script also runs a Trivy docker container 

### Debugging
Packer can easily be put into debug mode in which it'll write a temporary SSH key to disk and pause before each command. Simply set the environment variable `DEBUG=true` when calling `make build`. This can be useful if you need to SSH into a build to find out why a build failed.

### AMI Versioning:

Currently workflow tags ami's as following.
-   under `/bakery/images/` there are three images `example-ami, hello-world` and `rhel9.0-base`.
-   `rheal9.0-base` : base image (parent)
-   `example-ami`: child image
-   `hello-world`: child image
- you can build child image together i.e `example-ami, hello-world`
- It will fail buiding Parent and child as it should be. Parent image must be buils first.
 i.e `example-ami, rheal9.0-base`.
- Do not build parent and child together because child would not get latest updates from parent image.
- It tags incrementaly from `0.0.0`. Current tag will be applied to child OR parents image. As current logic applies currentl tag to all building images. 
i.e : if a current tag is `0.0.2` and apply changes to `example-ami` it takes current tag `example-ami-0.0.2` as starting point and updates to `example-ami-0.0.3`.


### IAM roles associated with Runner
Packer uses IAM permission associated with Runner Instance profile. In order for packer to work properly, minimal set permissions are needed. These can be referred at [Packer Buider Authentication Document](https://developer.hashicorp.com/packer/plugins/builders/amazon#authentication).
Current runner did not have these IAM policies and hence we had to add these manually. This could be taken as an improvement on AWS Infrastructure as Code that stands up the runner.


# Future Improvements
1. Concurrent Builds per image: At present if the first image in array it fails on buikd step it stops workflow.
It should build the second image regardless of first one failing.  
2. Pipeline must `fail` when `Critical` and `High` vulnerabilities are detected.
3. SSH inbound on EC2 runners should be limited to Github IPs
4. Runners should be started as a service
5. Runners should be able to obtain runner token dynamically
