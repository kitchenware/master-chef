if node.lsb.codename == "lucid" && node.apt.master_chef_add_apt_repo

  add_apt_repository "ppa_pgm" do
    url "http://ppa.launchpad.net/chris-lea/libpgm/ubuntu"
    key "C7917B12"
    key_server "keyserver.ubuntu.com"
  end

  add_apt_repository "ppa_zeromq_lucid" do
    url "http://ppa.launchpad.net/bpaquet/zeromq2-lucid/ubuntu"
    key "C4832F92"
    key_server "keyserver.ubuntu.com"
  end

end

if node.lsb.codename == "squeeze" && node.apt.master_chef_add_apt_repo

  add_apt_repository "squeeze-backports" do
    url "http://backports.debian.org/debian-backports"
    distrib "squeeze-backports"
    components ["main"]
  end

end

package "libzmq1"
