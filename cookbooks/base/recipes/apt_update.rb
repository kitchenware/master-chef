
if node['platform'] == "ubuntu" || node['platform'] == "debian"

  execute "apt-get update"

  if node.apt[:clean_sources_list_d]

    delayed_exec "Remove useless sources.list.d files" do
      block do
        vhosts = find_resources_by_name_pattern(/^\/etc\/apt\/sources.list.d\/.*\.conf$/).map{|r| r.name}
        Dir["/etc/apt/sources.list.d/*.conf"].each do |n|
          unless vhosts.include? n
            Chef::Log.info "Removing file #{n}"
            File.unlink n
          end
        end
      end
    end

  end

end