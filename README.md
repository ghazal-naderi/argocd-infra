# argocd-infra

# App of Apps Parent App repo

## What is AMI bakery?
The xxx repository provides the foundations for configuring, building a tool to  create an app that creates other apps, which in turn can create other apps. This allows us to declaratively manage a group of apps that can be deployed and configured in concert.


## App of Apps Parent App repo Design

![arch](assets/AMI-bakery-steps.svg)

## How to use this repository 
- Clone this using SSH : ```git@github.com:contino/ami-bakery.git```


# Prerequisites 
GitHub runner needs to have below tools installed 

* `A Kubernetes cluster`
* `ArgoCD running on the Kubernetes cluster with kustomize-heml plugin`


## Building A New Image
To create a new image, you can use the skeleton provided in `bakery/images/example-ami`. Just copy this  folder and paste it under `bakery/images`. Change the name of your AMI and then change each of the following files as required:
* `ansible/playbook.yml` - this file contains ansible config code to provison software/apps on top of source (base) image
* `packer-variables.json` - this file contains packer variables for image being build (e.g. source/base image information, name and tag of ami being created)

### Argocd Configuration
A single global `ami-bakery.pkr.hcl` file is used for all builds, and is parameterised with variables per image. See `bakery/images/<name>/packer-variables.json`.

**Useful Information** 
`global-packer-variables.pkrvars.hcl` contains global parameters for packer such as VPC/Subnet ID/AWS region where temp EC2 instance will be provisioned. Note that these ids should correspond to a valid VPC and a public subnet within it. Otherwise, packer builder will be unable to SSH to temp EC2 instance.


### Debugging
Packer can easily be put into debug mode in which it'll write a temporary SSH key to disk and pause before each command. Simply set the environment variable `DEBUG=true` when calling `make build`. This can be useful if you need to SSH into a build to find out why a build failed.


### Create the Dev Project
Once we’ve got our repos registered, the project needs to be created which create to encapsulate our application. as following the best practice of having a different project per environment.

`kubectl apply -f argocd/projects/project-dev.yml`



### Create the Root App


to create our Root App in ArgoCD run the following command.

`kubectl apply -f argocd/root-app-dev.yml`
As soon as we create our app, we can see it on the ArgoCD console with the status says Missing and OutOfSync. ArgoCD recognizes the Root App and its  children! It means that it knows that there are Application manifests for the children, and also even found them, but they haven’t actually been created in Kubernetes. In order to do that, we must run an argocd app sync.

### Create the Root App
To sync the Root App used the web UI sync botton.

### Create the Root App Cleanup

As we are make use of app of apps patern in when we delete the Root App, by default it deletes the Child Apps and all of their resourcesthat includes namespaces too. So we end up with a very clean delete.

# Future Improvements

1. 
