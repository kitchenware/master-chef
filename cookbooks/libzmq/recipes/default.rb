if node['platform'] == "ubuntu"

  base_ppa "pgm" do
    url "ppa:chris-lea/libpgm"
  end

  base_ppa "zeromq" do
     url "ppa:chris-lea/zeromq"
  end

end

package "libzmq1"
