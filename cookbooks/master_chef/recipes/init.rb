
ruby_block "dump_attributes" do
  block do
    File.write("/opt/master-chef/var/last/last_attributes.json", JSON.dump(node.to_hash), {:perm => "0600".to_i(8)})
  end
end
