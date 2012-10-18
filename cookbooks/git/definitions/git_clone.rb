
define :git_clone, {
  :reference => nil,
  :user => nil,
  :repository => nil,
  :notifies => nil,
  :clean_ignore => true,
} do

  git_clone_params = params

  raise "Please specify reference for using git_clone" unless git_clone_params[:reference]
  raise "Please specify user for using git_clone" unless git_clone_params[:user]
  raise "Please specify repository for using git_clone" unless git_clone_params[:repository]

  if node.git.auto_use_http_for_github && ENV['http_proxy'] && git_clone_params[:repository] =~ /^git:\/\/(github.com.*)/
    git_clone_params[:repository] = "http://#{$1}"
  end

  bash "git clone #{git_clone_params[:repository]} to #{git_clone_params[:name]}" do
    user git_clone_params[:user]
    code "git clone #{git_clone_params[:repository]} #{git_clone_params[:name]}"
    not_if "[ -d #{git_clone_params[:name]} ]"
    notifies git_clone_params[:notifies][0], git_clone_params[:notifies][1] if git_clone_params[:notifies]
  end

  clean_options = "-q -d -f"
  clean_options += " -x" if git_clone_params[:clean_ignore]

  bash "update git clone of #{git_clone_params[:repository]} to #{git_clone_params[:name]}" do
    user git_clone_params[:user]
    code "cd #{git_clone_params[:name]} && git reset --hard -q && git clean #{clean_options} && git checkout master && git pull && git checkout #{git_clone_params[:reference]}"
    not_if "cd #{git_clone_params[:name]} && git log -n1 --decorate | head -n 1 | grep #{git_clone_params[:reference]}"
    notifies git_clone_params[:notifies][0], git_clone_params[:notifies][1] if git_clone_params[:notifies]
  end

end