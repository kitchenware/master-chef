
if node.platform == 'debian'

  execute "active limits in pam common-session" do
    command 'echo -e "session required pam_limits.so" >> /etc/pam.d/common-session'
    not_if 'grep pam_limits.so /etc/pam.d/common-session'
  end

end
