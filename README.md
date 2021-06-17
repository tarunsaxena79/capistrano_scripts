# Capistrano_scripts

## Introduction

Simple capistrano deployment scripts to automate autoscaling servers deployment of PHP Stack.

## Use case
I have to deploy the code on multiple servers under AWS auto-scaling keeping in mind that no server comes up or goes down during deployment. The next task is to achieve the code integrity on all the servers at a time. All the servers must be running the same code from git repository.

`Note: Before moving to the solution, please ensure that:

- You have already setup Capistrano on a server which can login into an application node via key-based authentication and is able to deploy the code on it.
- You’ve used the files “deploy.rb” (if single environment) or staging.rb and production.rb (If multiple environments) to insert the remote IP of the application nodes.  
- The application node is able to SSH on the master Capistrano server to read some specific purpose text files (CURRENT_REVISION & PREVIOUS_REVISION) which I have used to make my solution more feasible (will be explained in the later part).
- All the application nodes and master Capistrano server should be authenticated  to clone git repository.

## Solution:
I followed two approaches to solve the whole use case:

### 1st approach:
There is a master Capistrano server which will be treated as the main utility server which can invoke the Capistrano’s tasks on application nodes.

Problems solved by this approach:

- You can trigger the deployments on all the production/staging instances from this utility server at a particular time.
- You can quickly rollback the code on all the servers to the previous version, if new code fails to execute.
- You need to make sure that while deploying, no new server in auto-scaling comes up or any current server goes down. For the time being, you need to pause your auto-scaling process. For this I’ve used AWS CLI to make the desired number of servers same as minimum and maximum value in auto-scaling group. Now the auto-scaling has been paused for the time you are deploying on the servers using Capistrano. Once, you are finished with the deployments, you can again set the values of auto-scaling group parameters to the previous values to make auto-scaling process active again. I’ve written some custom bash scripts to automate all this procedure. You can clone my git repository to use those scripts.
- Also, I’ve used two text files which I’ve mentioned above. The files are CURRENT_REVISION and PREVIOUS_REVISION. The CURRENT_REVISION file will store the git commit ID of the code which is currently running on the production servers. The file PREVIOUS_REVISION stores the git commit ID of the code which was previously deployed on the server. The intent of using these files is to make the rollback flow easier. I am updating the file CURRENT_REVISION after every successful deployment on all the production instances. The old value of file CURRENT_REVISION gets moved to PREVIOUS_REVISION once deployment is successful. The file CURRENT_REVISION will only get updated when you have deployed a new commit ID. If you are deploying the current commit ID again and again, the content of the files will not change. In this way, you can ensure that you always have commit ID of previous code in the file PREVIOUS_REVISION which you can use at the time of rollback.
- For quick rollback to previous version, Capistrano reads the content of the file PREVIOUS_REVISION and deploy that commit ID on all the production instances.
- You can also deploy a specific commit ID on all the production instances. For this, you need to pass the parameter cap -s branch=<commit_id_to_be_deployed>  deploy. This command will deploy the passed commit ID to all the remote servers mentioned inside ruby configuration file of Capistrano.  I’ve also made a script for the same.
- You can also shoot custom mails regarding the status of the deployment to the concerned person. I’ve used the sendmail utility to send custom mails.


### 2nd approach:
Once you have setup all this and your deployment process is working fine. As auto-scaling is active now, if any new server comes up then it will be having older code which you never want to happen.  You have to maintain the code integrity on all the servers. The new server which is coming up must have the latest code which is running on all the production instances. To achieve this, I have installed Capistrano on each application node.

Let us suppose, a new server is coming up under auto-scaling, then I’ve written a custom bash script, which will perform the following tasks at the startup time of the server :-

- The new server will first SSH on the master Capistrano server to read the content of the file CURRENT_REVISION to get the commit ID of the code, which is already running on all the production instances.
- After getting the commit ID, the application node will deploy the code of that git commit ID on itself as each application node is also a Capistrano node in itself. To make Capistrano deploy on itself, you can mention “localhost” in the remote IP in configuration file of Capistrano.
In this way, the code integrity will be achieved. You can download all the scripts from my git repository and can use in them accordingly.

Git repository URL : https://github.com/tarunsaxena79/capistrano_scripts

Blog Link - https://www.tothenew.com/blog/automating-deployment-using-capistrano-in-aws-auto-scaling/

___

Scripts for automating the deployment in autoscaling environment using Capistrano.

## How Does This Work 

Below is the quick description of the scripts:

### capistrano_deployment_all.sh

Bash script is designed to automate the deployment on all the servers simultaneously under Elastic Load Balancer in Autoscaling at a given point of time. Script will first get the IPs of all the running instances under autoscaling, and pass those IPs to Capistrano by editing its deploy.rb file.Moreover, the script will ensure that any new server is not being launched or getting shut down during the deployment. After the successful deployment, the script will send the Deployment status mail with the deployed git commit ID to the concerned person.In case of failed deployments the script, will rollback the code to the previous git commit ID.The script will store the current git commit ID in a text file named CURRENT_REVISION which is kept in the home directory of the <user> user and preserve the previous commit ID in the file named PREVIOUS_REVISION.

#### Pre-requisites 

- CURRENT_REVISION file in home directory of user(/home/<user>/CURRENT_REVISION)
- PREVIOUS_REVISION file in home directory of user (/home/<user>/PREVIOUS_REVISION)

-----

### capistrano_deployment_rollback.sh

The script is intended to be used to quickly rollback the code on all the servers to the previous deployed revision.

#### Pre-requisites

- CURRENT_REVISION file in home directory of <user> user(/home/<user>/CURRENT_REVISION)
- PREVIOUS_REVISION file in home directory of <user> user (/home/<user>/PREVIOUS_REVISION)

-----

### capistrano_deployment_specific_commit.sh

The script will ask for the commit ID to be deployed on all the servers.This script will be used when the team wants to deploy a specific commit ID on all the servers.

#### Pre-requisites

- CURRENT_REVISION file in home directory of <user> user(/home/<user>/CURRENT_REVISION)
- PREVIOUS_REVISION file in home directory of <user> user (/home/<user>/PREVIOUS_REVISION)

-----

### capistrano_deployment_status.sh

This script will show the overall deployment status on all the servers at a time.When you run this script from Capistrano’s node, It will display the instanceID, Public IP and currently deployed git commit ID on the server.

----

### capistrano_deployment_specific_IP.sh

This script is basically meant for the deployment on staging server, before taking the code to the production environment.It will ask for the IP of the server and the commit ID for the code which needs to be deployed.The script maintains different git revisions file for the staging server.The revision files are named as QA_PREVIOUS_REVISION and QA_CURRENT_REVISION.

----

### capistrano_deployment_specific_IP_rollback.sh

This script is basically meant for the rollback on staging server.It will only ask for the IP of the server on which the code needs to be rollbacked.

---

### custom_init_script.sh

This script is meant for the instances being launched in autoscaling.The instance will get currently deployed commit id from Capistrano master node, and will deploy the code on itself followed by mail acknowledgement.

Working :- When a new autoscaling server is being launched, the script runs in rc.local, and login into Capistrano server to read the currently deployed GIT commit ID and then deploys the code of that commit ID on itself.

#### Pre-requisites

As each server will be logging into the master Capistrano for reading the file CURRENT_REVISION, so the <user> user on the application node must be able to login into Capistrano node by key-based authentication.For this, add application’s node’s <user> user’s public key in authorised keys of Capistrano server’s <user> user.

- CURRENT_REVISION file in home directory of <user> user(/home/<user>/CURRENT_REVISION)
- PREVIOUS_REVISION file in home directory of <user> user (/home/<user>/PREVIOUS_REVISION)

The script custom_init_script.sh has been placed in the home directory of <user> user on every autoscaling server which is being launched from the AMI.The script runs in the rc.local of every autoscaled instance.

----

Capistrano's configuration files' templates :-

- deploy.rb
- staging.rb
- production.rb

---

**Note** :- Please note the "#######" pattern in all the configuration files(staging.rb/production.rb), all the scripts use this pattern to insert remote IPs in the configuration files.Without this the scripts wont' work.

# How to Contribute

- Fork the repository
- Submit a pull request to master branch of this repository
- Reach out to tarunsaxena79@gmail.com 

