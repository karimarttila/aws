# Simple Server AWS EKS Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [Making the Clojure Simple Server Stateless](#making-the-clojure-simple-server-stateless)
- [Simple Server Clojure Docker Image](#simple-server-clojure-docker-image)
- [AWS Infrastructure](#aws-infrastructure)
  - [Terraform State](#terraform-state)
  - [Terraform Project Structure](#terraform-project-structure)
  - [Terraform Module Example](#terraform-module-example)
- [Kubernetes Configuration](#kubernetes-configuration)
- [Testing the Kubernetes Configuration Using Minikube](#testing-the-kubernetes-configuration-using-minikube)
- [Kubernetes Deployment to AWS EKS](#kubernetes-deployment-to-aws-eks)
- [Demonstration Using AWS EKS](#demonstration-using-aws-eks)



# Introduction

After implementing the Simple Server in [five languages](https://medium.com/@kari.marttila/five-languages-five-stories-1afd7b0b583f) I was wondering what to do next. Since I have been working on the Azure side for the past 6 months (in my corporate universe) I thought that it would be good to refresh my [AWS](https://aws.amazon.com/) skills in my personal parallel universe - so why not change the Clojure Simple Server Implementation a bit to make it stateless, then create a [Docker](https://www.docker.com) image for the Simple Server and deploy the Simple Server Docker containers to AWS [EKS](https://aws.amazon.com/eks/) - Amazon Elastic Container Service for Kubernetes.


# Making the Clojure Simple Server Stateless

The [Clojure Simple Server](https://github.com/karimarttila/clojure/tree/master/clj-ring-cljs-reagent-demo/simple-server) was initially a statefull server since it was implemented just for demonstration purposes. You can deploy the statefull version to Kubernetes, of course, but making many pods for the configuration doesn't make sense since the server is statefull and if you add a load balancer to the configuration your requests can go to any pod. Therefore for demonstration purposes I made the Clojure Simple Server stateless storing the session state in AWS DynamoDB (TODO: TO BE DONE). The [simpleserver.properties](https://github.com/karimarttila/clojure/tree/master/clj-ring-cljs-reagent-demo/simple-server) has a property session-state which can have two values: local / dynamodb - local is the old local session state (statefull), dynamodb version stores the product data, user data and sessions to [DynamoDB](https://aws.amazon.com/dynamodb/) making the server effectively stateless (e.g. requests with token can go to any instance - the server validates the session using DynamoDB).


# Simple Server Clojure Docker Image

You can find the [The Simple Server Clojure Docker Image](https://github.com/karimarttila/docker/tree/master/simple-server/clojure) in my Github account. There are build scripts which make building of the Simple Server Docker image pretty easy.


# AWS Infrastructure

I'm using Terraform to create the needed AWS infrastructure.

## Terraform State

For storing the Terraform state I'm using [S3](https://aws.amazon.com/s3/) [terraform backend](https://www.terraform.io/docs/backends/). See [env.tf](https://github.com/karimarttila/aws/blob/master/simple-server-eks/terraform/envs/dev/env.tf) how to configure a Terraform backend. Basically there is no need to configure a backend in a single-user project but let's do it professionally to demonstrate Terraform best practices as well. 

## Terraform Project Structure

I'm using a Terraform structure in which I have environments ([envs](https://github.com/karimarttila/aws/tree/master/simple-server-eks/terraform/envs)) and [modules](TODO). Environments define the environments and they reuse the entities defined in the modules directory. 

## Terraform Module Example

TODO


# Kubernetes Configuration

TODO

# Testing the Kubernetes Configuration Using Minikube

TODO


# Kubernetes Deployment to AWS EKS

TODO


# Demonstration Using AWS EKS

TODO: Demo, Dashboard, logs etc.









