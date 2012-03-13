
define :base_allow_github, {

  } do

  base_allow_github_params = params

  execute "Allow connection to github to #{base_allow_github_params[:name]}" do
    user base_allow_github_params[:name]
    command <<-EOH
    ssh -o StrictHostKeyChecking=no git@github.com 'echo' || true
    EOH
    not_if "ssh-keygen -F github.com -f #{get_home base_allow_github_params[:name]}/.ssh/known_hosts | grep github.com"
  end

end