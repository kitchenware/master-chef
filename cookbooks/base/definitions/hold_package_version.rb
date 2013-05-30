
define :hold_package_version, {
} do
  hold_package_version_params = params

  execute "fix #{hold_package_version_params[:name]} version" do
    command "echo #{hold_package_version_params[:name]} hold | dpkg --set-selections"
    not_if "dpkg --get-selections | grep #{hold_package_version_params[:name]} | grep -q hold"
  end

end