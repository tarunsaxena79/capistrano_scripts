# capistrano_scripts
Scripts for automating the deployment in autoscaling environment using Capistrano

1.capistrano_deployment_all.sh :- 
Bash script is designed to automate the deployment on all the servers simultaneously under Elastic Load Balancer in Autoscaling at a given point of time. Script will first get the IPs of all the running instances under autoscaling, and pass those IPs to Capistrano by editing its deploy.rb file.Moreover, the script will ensure that any new server is not being launched or getting shut down during the deployment. After the successful deployment, the script will send the Deployment status mail with the deployed git commit ID to the concerned person.In case of failed deployments the script, will rollback the code to the previous git commit ID.The script will store the current git commit ID in a text file named CURRENT_REVISION which is kept in the home directory of the <user> user and preserve the previous commit ID in the file named PREVIOUS_REVISION.

Pre-requisites :-
-CURRENT_REVISION file in home directory of  user(/home/<user>/CURRENT_REVISION)
-PREVIOUS_REVISION file in home directory of  user (/home/<user>/PREVIOUS_REVISION)


-------------------------------------------------------------------------------------------

2.capistrano_deployment_rollback.sh :- 
The script is intended to be used to quickly rollback the code on all the servers to the previous deployed revision.

Pre-requisites :-
-CURRENT_REVISION file in home directory of <user> user(/home/<user>/CURRENT_REVISION)
-PREVIOUS_REVISION file in home directory of <user> user (/home/<user>/PREVIOUS_REVISION)


-------------------------------------------------------------------------------------------

3.capistrano_deployment_specific_commit.sh :- 
The script will ask for the commit ID to be deployed on all the servers.This script will be used when the team wants to deploy a  specific commit ID on all the servers.

Pre-requisites :-
-CURRENT_REVISION file in home directory of <user> user(/home/<user>/CURRENT_REVISION)
-PREVIOUS_REVISION file in home directory of <user> user (/home/<user>/PREVIOUS_REVISION)


-------------------------------------------------------------------------------------------

4.capistrano_deployment_status.sh :- 
This script will show the overall deployment status on all the servers at a time.When you run this script from Capistrano’s node, It will display the instanceID, Public IP and currently deployed git commit ID on the server.


-------------------------------------------------------------------------------------------

5.capistrano_deployment_specific_IP.sh :- 
This script is basically meant for the deployment on staging server, before taking the code to the production environment.It will ask for the IP of the server and the commit ID for the code which needs to be deployed.The script maintains different git revisions file for the staging server.The revision files are named as QA_PREVIOUS_REVISION and QA_CURRENT_REVISION.

-------------------------------------------------------------------------------------------

6.capistrano_deployment_specific_IP_rollback.sh :-
This script is basically meant for the rollback on staging server.It will only ask for the IP of the server on which the code needs to be rollbacked.

-------------------------------------------------------------------------------------------

7.custom_init_script.sh :- 
This script is meant for the instances being launched in autoscaling.The instance will get currently deployed commit id from Capistrano master node, and will deploy the code on itself followed by mail acknowledgement.
Working :- When a new autoscaling server is being launched, the script runs in rc.local, and login into Capistrano server to read the currently deployed GIT commit ID and then deploys the code of that commit ID on itself.
Pre-requisites :-
As each server will be logging into the master Capistrano for reading the file CURRENT_REVISION, so the <user> user on the application node must be able to login into Capistrano node by key-based authentication.For this, add application’s node’s <user> user’s public key in authorised keys of Capistrano server’s <user> user.
CURRENT_REVISION file in home directory of <user> user(/home/<user>/CURRENT_REVISION)
PREVIOUS_REVISION file in home directory of <user> user (/home/<user>/PREVIOUS_REVISION)


 The script custom_init_script.sh has been placed in the home directory of <user> user on every autoscaling server which is being launched from the AMI.The script runs in the rc.local of every autoscaled instance.

-------------------------------------------------------------------------------------------

Capistrano's configuration files' templates  :- 
-deploy.rb
-staging.rb
-production.rb 

<<<<<<< HEAD
=============================================================================================================================================================================================

Note :- Please note the "#######" pattern in all the configuration files, all the scripts use this pattern to insert remote IPs in the configuration files.Without this the scripts wont' work.

=============================================================================================================================================================================================
