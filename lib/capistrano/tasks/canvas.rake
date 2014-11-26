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
      execute "ln -s #{shared_path}/files #{release_path}/tmp/files"
    end
  end

  task :log_deploy do ; end

end
