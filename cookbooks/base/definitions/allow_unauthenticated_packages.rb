define :authorize_unauthenticated_packages, {
} do
  package "debian-archive-keyring"
  
  template "/etc/apt/apt.conf.d/allow_not_authenticated_packages" do
    cookbook "base"
    source "allow_not_authenticated_packages.erb"
  mode 0644
  end

end