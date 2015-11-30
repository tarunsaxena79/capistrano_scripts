######
role :app,"xxx.xxx.xxx.xxx"

after "deploy:restart", "deploy:cleanup"

 namespace :deploy do
   task :restart, :roles => :app  do
     run "#{try_sudo} <custom bash commands>"
     run "#{try_sudo} <custom bash commands>"
     run "sudo service xxxx restart"	
   end
 end
