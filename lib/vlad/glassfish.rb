require 'vlad'

namespace :vlad do
  ##
  # Glassfish app server

  set :glassfish_jruby_path     '/usr/jruby'
  set :glassfish_command,       'glassfish_rails'
  set :glassfish_contextroot,  '/'
  set :glassfish_port,          8000
  set :glassfish_environment,   "production"
  set :glassfish_runtimes,      2
  set :glassfish_min_runtimes,  1
  set :glassfish_max_runtimes,  1
  set :glassfish_daemon,        true
  set :glassfish_pid_file,      nil
  set :glassfish_log_file,      nil
  set :glassfish_log_level,     3
  set :glassfish_conf          "#{shared_path}/config/glassfish.yml"

  desc "Prepares application servers for deployment. Glassfish
configuration is set via the glassfish_* variables.".cleanup

  remote_task :setup_app, :roles => :app do
    cmd = [
          "#{glassfish_jruby_path}/bin/jruby -S",
           "#{glassfish_command}",
           "-c #{glassfish_contextroot}",
           "-p #{glassfish_port}",
           "-e #{glassfish_environment}",
           "-n #{glassfish_runtimes}",
           "--runtimes-min #{glassfish_min_runtimes}",
           "--runtimes-max #{glassfish_max_runtimes}",
           ("-d" if glassfish_daemon),
           ("-P #{glassfish_pid_file}" if glassfish_pid_file),
           ("-l #{glassfish_log_file}" if glassfish_log_file),
           "--log-level #{glassfish_log_level}",
           "--config #{glassfish_conf}",
          ].compact.join ' '

    run cmd
  end

  desc "Restart the app servers"
  remote_task :start_app, :roles => :app do
    Rake::RemoteTask["stop_app"].invoke
    Rake::RemoteTask["setup_app"].invoke
  end

  desc "Stop the app servers"
  remote_task :stop_app, :roles => :app do
    system("kill -INT #{glassfish_pid_file}")
  end
end
