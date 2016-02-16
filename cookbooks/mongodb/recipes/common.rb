if node.platform == "ubuntu" && node.apt.master_chef_add_apt_repo

  add_apt_repository "ubuntu_10gen" do
    url "http://downloads-distro.mongodb.org/repo/ubuntu-upstart"
    distrib "dist"
    components ['10gen']
    key "7F0CEB10"
    key_url "https://docs.mongodb.org/10gen-gpg-key.asc"
    run_apt_get_update true
  end
end

if node.platform == "debian" && node.apt.master_chef_add_apt_repo

  add_apt_repository "ubuntu_10gen" do
    url "http://downloads-distro.mongodb.org/repo/debian-sysvinit"
    distrib "dist"
    components ['10gen']
    key "7F0CEB10"
    key_url "https://docs.mongodb.org/10gen-gpg-key.asc"
    run_apt_get_update true
  end
end
