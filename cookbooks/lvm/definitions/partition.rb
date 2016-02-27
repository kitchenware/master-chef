
define :partition, {
  :fs_type => nil,
} do

  root = params[:name].match(/^(.*)\d+$/)[1]

  execute "create partition #{params[:name]} on #{root}" do
    command "parted --script --align optimal #{root} mkpart primary #{params[:fs_type] || 'ext4'} $(parted #{root} unit MiB print free | grep Free | tail -n 1 | awk '{print $1}') 100%"
    not_if "[ -e #{params[:name]} ]"
  end

end
