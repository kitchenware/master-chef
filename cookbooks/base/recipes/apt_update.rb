
if node.platform == "ubuntu" || node.platform == "debian"

  execute "run apt-get update" do
    command "apt-get update"
  end

  if node.apt[:clean_sources_list_d]

    delayed_exec "Remove useless sources.list.d files" do
      block do
        repos = find_resources_by_name_pattern(/^\/etc\/apt\/sources.list.d\/.*\.list$/).map{|r| r.name}
        Dir["/etc/apt/sources.list.d/*.list"].each do |n|
          unless repos.include? n
            Chef::Log.info "Removing file #{n}"
            File.unlink n
          end
        end
      end
    end

  end

end