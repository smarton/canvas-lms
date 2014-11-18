namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:all) do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
end

namespace :canvas do

  desc "Fix ownership on canvas install directory"
  task :fix_owner do
    on roles(:all) do
      user = fetch :user
      execute :chown, '-R', "#{user}:#{user}", "#{release_path}"
    end
  end

  desc "Copy configuration files"
  task :copy_config do
    on roles(:all) do
      execute :cp, "#{shared_path}/config/*.yml", "#{release_path}/config"
    end
  end

  desc "Ping the canvas servers to restart passenger"
  task :ping do
    on roles(:all) do
      execute "curl -m 10 --silent http://localhost/login?canvas_login=true"
    end
  end

  desc "Create symlink for files folder to mount point"
  task :symlink_canvasfiles do
    on roles(:all) do
      execute "mkdir -p #{release_path}/tmp/files && ln -s #{shared_path}/tmp/files #{release_path}/tmp/files"
    end
  end

  task :log_deploy do ; end

end

Rake::Task["canvas:meta_tasks:before_updated"].clear_actions
namespace :meta_tasks do
  desc "Additional tasks that need to run before _updated_"
  task :before_updated do
    invoke 'canvas:copy_config'
    invoke 'canvas:fix_owner'
    invoke 'canvas:clone_qtimigrationtool'
    invoke 'canvas:symlink_canvasfiles'
    invoke 'canvas:migrate_predeploy'
    invoke 'canvas:compile_assets'
  end
end