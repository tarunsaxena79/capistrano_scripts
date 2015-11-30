#!/bin/bash
Deployment_status=1 #deployment unsuccessful
unset ip
unset commit_id
echo "=========Welcome to rollback testing on specific QA Server============"
echo "Enter the IP of the QA server on which code is to be deployed:"
read ip
old_commit_id=`cat /home/<user>/QA_CURRENT_REVISION`
prev_commit_id=`cat /home/<user>/QA_PREVIOUS_REVISION`
	IP_format=`echo $ip | sed 's/^/\"/' | sed 's/$/\"/'`
	echo "present directory :-`pwd`"
	sed -i "/role\ \:app/d" <path to prodcution.rb/staging.rb file to append IP under roles tag>
	sed -i '/######/a role\ :app,'$IP_format'' <path to prodcution.rb/staging.rb file to append IP under roles tag>
	cd /home/<user>/<directory in which capistrano is initialized (capify . command is run)>
	cap staging -s branch="$prev_commit_id"  deploy
	if [ $? == 0 ]
        then
		echo "rollback successful"
		Deployment_status=0;
		echo "Fetching latest git commit from the server with public IP :"$ip
		commit_id=`ssh -oStrictHostKeyChecking=no <user>@"$ip" cat /var/www/<document_root>/current/REVISION`
		echo "=========UPDATING CURRENT_REVISION FILE WITH NEW COMMIT ID=========="
	        echo "$commit_id" > /home/<user>/QA_CURRENT_REVISION
		if [ $commit_id = $old_commit_id ]
                        then
                                echo "!!!!!!!!!!!!!!error...rollback commit ID and latest commit ID can't be same!!!!!!!!!! " ;
                        else
                                echo "========PREVIOUS COMMIT DETECTED...UPDATING PREVIOUS_REVISION FILE WITH PREVIOUS COMMIT ID=========="
                                echo "$old_commit_id" > /home/<user>/QA_PREVIOUS_REVISION
                fi
        else
		echo "rollback failed"
	fi
	#Mail Acknowledgement of the deployment status
	if [ $Deployment_status == 0 ]
	then 
		echo "successful"
        	( echo "Subject: Previous Commit ID Deployment Successful on the specified QA server :- $ip" ; echo "The Git commit ID $commit_id has been successfully deployed  on the specified QA server with IP : $ip" ) | /usr/sbin/sendmail -F Deployment-Alert <emailID>
        else
        ( echo "Subject: Rollback failed on the specified QA servers :- $ip" ; echo "Deployment failed on the specified QA servers --Rollbacking to the previous commit ID - $old_commit_id" ) | /usr/sbin/sendmail -F Deployment-Alert <emailID>
	echo "!!!!!!!!!!!!!!!!!!!Restricting to the old commit!!!!!!!!!!!!!!!!!!!"
fi
cd /home/<user>
