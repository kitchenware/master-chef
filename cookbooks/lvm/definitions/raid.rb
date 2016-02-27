
define :raid, {
  :disks => nil,
  :level => nil,
} do

  raise "Please specify disks" unless params[:disks]

  params[:disks].each do |x|
    if x .match (/^(.*)(\d)+$/)
      root, k = $1, $2
      execute "set raid flag on #{x}" do
        command "parted #{root} set #{k} raid on"
        not_if "parted #{root} print | grep raid | awk '{print $1}' | grep #{k}"
      end
    end
  end

  execute "create raid array #{params[:name]}" do
    command "mdadm --create #{params[:name]} --continue --level=#{params[:level] || '1'} --raid-devices=#{params[:disks].size} --metadata=0.90 #{params[:disks].join(' ')}"
    not_if "[ -e #{params[:name]} ]"
  end

  execute "fix mdadm.conf for #{params[:name]}" do
    command "mdadm --examine --scan | grep ' #{params[:name]} ' >> /etc/mdadm/mdadm.conf "
    not_if "cat /etc/mdadm/mdadm.conf | grep ' #{params[:name]} '"
  end

end
