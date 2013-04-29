define :hold_package_version, {
  :packages => [],
} do
  hold_package_version_params = params
  packages = hold_package_version_params[:packages]
  packages.each do |package|
    execute "fix #{package} version" do
      command "echo #{package} hold | dpkg --set-selections"
      not_if "dpkg --get-selections | grep #{package} | grep -q hold"
    end
  end

end