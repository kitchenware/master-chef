if node.lsb.codename == "lucid" && node.apt.master_chef_add_apt_repo

  base_ppa "pgm" do
    url "ppa:chris-lea/libpgm"
  end

  base_ppa "zeromq" do
     url "ppa:bpaquet/zeromq2-lucid"
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
