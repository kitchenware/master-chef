
if node[:symlink_folders]

  node.symlink_folders.each do |k, v|

    symlink_folder k do
      target v[:target]
      impacted_services v[:impacted_services] if v[:impacted_services]
    end

  end

end