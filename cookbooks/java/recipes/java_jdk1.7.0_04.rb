
jdk = "jdk1.7.0_04"
warp_file = "#{jdk}_`arch`.warp"

bash "install oracle jdk7" do
  code "cd /tmp && wget #{node.warp.warp_src}/#{warp_file} && sh #{warp_file} && rm #{warp_file}"
  not_if "[ -d /usr/lib/jvm/#{jdk} ]"
end

bash "update alternative jdk7" do
  code <<-EOF
  update-alternatives --install /usr/bin/java java /usr/lib/jvm/#{jdk}/bin/java 1 &&
  update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/#{jdk}/bin/javac 1
  EOF
  not_if "update-alternatives --list java | grep #{jdk}"
end
