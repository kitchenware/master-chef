
define :hold_package_version, {
} do
  hold_package_version_params = params

  execute "hold #{hold_package_version_params[:name]} version" do
    command "echo #{hold_package_version_params[:name]} hold | dpkg --set-selections"
    not_if "dpkg --get-selections | grep #{hold_package_version_params[:name]} | grep -q hold"
  end

end

define :package_fixed_version, {
  :version => nil,
} do
  package_fixed_version_params = params

  raise "Please specify version with package_fixed_version" unless package_fixed_version_params[:version]

  package package_fixed_version_params[:name] do
    version package_fixed_version_params[:version]
    options "--force-yes"
  end

  hold_package_version package_fixed_version_params[:name]

end