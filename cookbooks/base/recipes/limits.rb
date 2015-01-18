
execute "active limits in pam common-session" do
  command 'echo "session required pam_limits.so" >> /etc/pam.d/common-session-noninteractive'
  not_if 'grep pam_limits.so /etc/pam.d/common-session-noninteractive'
end
