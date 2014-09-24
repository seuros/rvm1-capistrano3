namespace :rvm1 do
  namespace :install do
    desc "Installs RVM 1.x user mode"
    task :rvm do
      on roles(fetch(:rvm1_roles, :all)) do
        execute :mkdir, "-p", "#{fetch(:tmp_dir)}/#{fetch(:application)}/"
        upload! File.expand_path("../../../../../script/install-rvm.sh", __FILE__), "#{fetch(:tmp_dir)}/#{fetch(:application)}/install-rvm.sh"
        execute :chmod, "+x", "#{fetch(:tmp_dir)}/#{fetch(:application)}/install-rvm.sh"
        execute "#{fetch(:tmp_dir)}/#{fetch(:application)}/install-rvm.sh"
      end
    end
    before :rvm, 'rvm1:hook'

    desc "Installs Ruby for the given ruby project"
    task :ruby do
      on roles(fetch(:rvm1_roles, :all)) do
        within fetch(:release_path) do
          execute "#{fetch(:tmp_dir)}/#{fetch(:application)}/rvm-auto.sh", "rvm", "--install", "install", fetch(:rvm1_ruby_version)
        end
      end
    end
    before :ruby, "deploy:updating"
    before :ruby, 'rvm1:hook'

    desc "Install gems from Gemfile into gemset using rubygems."
    task :gems do
      on roles(fetch(:rvm1_roles, :all)) do
        within release_path do
          execute :gem, "install", "--file", "Gemfile"
        end
      end
    end
    before :gems, "deploy:updating"
    before :gems, 'rvm1:hook'

  end

  namespace :alias do
    desc "Create an alias for the given"
    task :create do
      on roles(fetch(:rvm1_roles, :all)) do
        within fetch(:release_path) do
          execute "#{fetch(:tmp_dir)}/#{fetch(:application)}/rvm-auto.sh",
            fetch(:rvm1_ruby_version), "rvm", "alias", "create",
            fetch(:rvm1_alias_name), "current"
        end
      end
    end
    before :create, "deploy:updating"
    before :create, 'rvm1:hook'
  end
end
