#!/bin/bash
ELB_Name=<ELB_NAME>
Region=<AWS_REGION>
AUTO_SCALING_Group=<AUTOSCALING GROUP>
	Instance_IDs=($(aws elb describe-load-balancers --load-balancer-names $ELB_Name --query 'LoadBalancerDescriptions[].Instances[].InstanceId'  --output text))
	echo "THE DEPLOYMENT STATUS ON ALL THE SERVERS ARE GIVEN BELOW"

	  for i in "${Instance_IDs[@]}"
        	do
                	public_IP=($(aws ec2 describe-instances --instance-ids $i --query 'Reservations[].Instances[].PublicIpAddress' --output text))
		        commit_id=`ssh -oStrictHostKeyChecking=no <user>@"$public_IP" cat /var/www/<document_root>/current/REVISION`
		        echo "INSTANCE :$i=====IP ADDRESS :$public_IP=========COMMIT-ID :$commit_id"
		done
