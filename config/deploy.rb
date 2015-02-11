lock '3.2.1'

set :application,   'canvas'
set :repo_url,      'https://github.com/smarton/canvas-lms.git'
set :scm,           'git'
set :branch,        ENV['branch'] || 'smarton-deploy'
set :user,          'ubuntu'
set :deploy_to,     '/var/canvas'
set :rails_env,     'production'
set :linked_dirs,   %w{log tmp/pids public/system}
set :log_level,     ENV['log_level'] || :debug
set :pty,           true

set :bundle_path, "vendor/bundle"
set :bundle_without, nil
set :bundle_flags,  ""

set :ssh_options, {
  forward_agent: true,
  user: 'ubuntu'
}
if (ENV.has_key?('gateway'))
  require 'net/ssh/proxy/command'
  gateway_user =  ENV['gateway_user'] || ENV['USER']

  set :ssh_options, {
    proxy: Net::SSH::Proxy::Command.new("ssh #{gateway_user}@#{ENV['gateway']} -W %h:%p"),
    forward_agent: true,
    keys: [ENV['gateway_key']],
    user: 'ubuntu'
  }
end

namespace :canvas do
  
  desc "TEMP Rollback Analytics to e810a1 to work around compile_assets problem"
  task :analytcs_rollback do
    on roles(:all) do
      within "#{release_path}/gems/plugins/analytics" do
        execute :git, 'checkout', 'e810a1a126ac4c47c411507251041420402fd02b'
      end
    end
  end
  
  namespace :meta_tasks do
    
    desc "Tasks that need to run before _updated_"
    Rake::Task["before_updated"].clear_actions
    task :before_updated do
      invoke 'canvas:copy_config'
      invoke 'canvas:fix_owner'
      invoke 'canvas:clone_qtimigrationtool'
      invoke 'canvas:clone_analytics'
      invoke 'canvas:analytics_rollback'
      invoke 'canvas:symlink_canvasfiles'
      invoke 'canvas:migrate_predeploy'
      invoke 'canvas:compile_assets'
    end

  end
end

namespace :deploy do
  before :updated,  'canvas:meta_tasks:before_updated'
  after :updated,   'canvas:meta_tasks:after_updated'
  after :published, 'canvas:meta_tasks:after_published'
end
