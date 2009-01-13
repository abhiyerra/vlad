require 'vlad'
namespace :vlad do
  set :merb_address,       "127.0.0.1"
  set :merb_adapter,       'thin'
  set :merb_command,       './bin/merb'
  set :merb_environment,   'production'
  set :merb_port,          4000
  set :merb_servers,       1
  
  def merb(cmd)
    "cd #{current_path} && #{merb_command} -a #{merb_adapter} -p #{merb_port} -c #{merb_servers} -e #{merb_environment} #{cmd}"
  end

  remote_task :stop_app, :roles => [:app] do
    run merb("-K all")
  end
  remote_task :start_app, :roles => [:app] do
    run merb('')
  end

  remote_task :symlink_configs, :roles => [:app] do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml && mkdir -p #{release_path}/tmp/cache"
  end
  
  namespace :dm do
    remote_task :migrate, :roles => [:db] do
      run "cd #{current_path}; MERB_ENV=#{merb_env} rake dm:db:migrate"
    end
  end
end
