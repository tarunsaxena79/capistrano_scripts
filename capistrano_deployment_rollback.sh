#!/bin/bash
ELB_Name=<ELB_NAME>
Region=<AWS_REGION>
AUTO_SCALING_Group=<AUTOSCALING GROUP>
Deployment_status=1 #deployment unsuccessful
old_commit_id=`cat /home/<user>/CURRENT_REVISION`	
	old_min_size=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $AUTO_SCALING_Group --query 'AutoScalingGroups[].MinSize[]' --output text`
        old_max_size=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $AUTO_SCALING_Group --query 'AutoScalingGroups[].MaxSize[]' --output text`
        old_desired_capacity=`aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $AUTO_SCALING_Group --query 'AutoScalingGroups[].DesiredCapacity[]' --output text`

	echo "===============RESTRICTING AUTOSCALING TO AVOID ANY NEW CHANGES IN MIN/MAX/DESIRED CONFIGURATIONS, PLEASE WAIT==============="
        sleep 10
        aws autoscaling update-auto-scaling-group --auto-scaling-group-name $AUTO_SCALING_Group --min-size $old_desired_capacity --output text
        aws autoscaling update-auto-scaling-group --auto-scaling-group-name $AUTO_SCALING_Group --max-size $old_desired_capacity --output text
        sleep 10

	Instance_IDs=($(aws elb describe-load-balancers --load-balancer-names $ELB_Name --query 'LoadBalancerDescriptions[].Instances[].InstanceId'  --output text))

	for i in "${Instance_IDs[@]}"
	do 
		public_IP=`aws ec2 describe-instances --instance-ids $i --query 'Reservations[].Instances[].PublicIpAddress' --output text`
		IPs=$IPs,"$public_IP"
	done
	
	IP_format=`echo $IPs | sed 's/,/"/'|sed 's/,/","/g' | sed 's/$/"/'`
	echo "Appending this format to Capistrano's deploy.rb under :role tag:"$IP_format	
	echo "present directory :-`pwd`"
	mail_IP_format=`echo "$IPs"|sed  's/,//'`
	sed -i "/role\ \:app/d" <path to prodcution.rb/staging.rb file to append IP under roles tag>
	sed -i '/######/a role\ :app,'$IP_format'' <path to prodcution.rb/staging.rb file to append IP under roles tag>
	cd /home/<user>/<directory in which capistrano is initialized (capify . command is run)>
	cap deploy:rollback
	        if [ $? == 0 ]
        	then
                echo "Deployment successful"
                Deployment_status=0;
                echo "Fetching latest git commit from the server with public IP :"$public_IP
                commit_id=`ssh -oStrictHostKeyChecking=no  <user>@"$public_IP" cat /var/www/html/REVISION`
                echo "=========UPDATING CURRENT_REVISION FILE WITH NEW COMMIT ID=========="
                echo "$commit_id" > /home/<user>/CURRENT_REVISION
                        if [ $commit_id = $old_commit_id ]
                        then
                                echo "!!!!!!!!!!!!!!error...rollback commit ID and latest commit ID can't be same!!!!!!!!!! " ;
                        else
                                echo "=========PREVIOUS COMMIT DETECTED...UPDATING PREVIOUS_REVISION FILE WITH PREVIOUS COMMIT ID=========="
                                echo "$old_commit_id" > /home/<user>/PREVIOUS_REVISION
                        fi
                else
                echo "Deployment failed"
                fi


		 if [ $Deployment_status == 0 ]
                then
                ( echo "Subject: Deployemnt Rollbacked Successfully on the All the Servers" ; echo "The old Git commit ID $commit_id has been successfully deployed  on all the servers under ELB.The IP of the servers are $mail_IP_format" ) | /usr/sbin/sendmail -F Deployment-Alert <emailID>
                else
                ( echo "Subject: Deployemnt failed on the servers" ; echo "Deployment failed on the servers--" ) | /usr/sbin/sendmail -F Deployment-Alert <emailID>
                fi

	echo "===============SETTING AUTOSCALING VARIABLES (MIN/MAX/DESIRED CONFIGURATIONS) TO THEIR PREVIOUS VALUE, PLEASE WAIT==============="
        sleep 10
        aws autoscaling update-auto-scaling-group --auto-scaling-group-name $AUTO_SCALING_Group --min-size $old_min_size --output text
        aws autoscaling update-auto-scaling-group --auto-scaling-group-name $AUTO_SCALING_Group --max-size $old_max_size --output text
        if [ $? == 0 ]
        then
                echo "AUTOSCALING CONFIGURATIONS REVERTED SUCCESSFULLY"
        else
                echo "AUTOSCALING CONFIGURATIONS FAILED TO REVERT, PLEASE CHECK YOUR CREDENTIALS"
        fi
cd /home/<user>
