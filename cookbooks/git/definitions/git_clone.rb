
define :git_clone, {
  :reference => nil,
  :user => nil,
  :repository => nil,
} do

  git_clone_params = params

  raise "Please specify reference for using git_clone" unless git_clone_params[:reference]
  raise "Please specify user for using git_clone" unless git_clone_params[:user]
  raise "Please specify repository for using git_clone" unless git_clone_params[:repository]

  bash "git clone #{git_clone_params[:repository]} to #{git_clone_params[:name]}" do
    user git_clone_params[:user]
    code "git clone #{git_clone_params[:repository]} #{git_clone_params[:name]}"
    not_if "[ -d #{git_clone_params[:name]} ]"
  end

  bash "update git clone of #{git_clone_params[:repository]}" do
    user git_clone_params[:user]
    code "cd #{git_clone_params[:name]} && git checkout master && git pull && git checkout #{git_clone_params[:reference]}"
    not_if "cd #{git_clone_params[:name]} && git log -n1 --decorate | head -n 1 | grep #{git_clone_params[:reference]}"
  end

end