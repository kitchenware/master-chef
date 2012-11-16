
if node[:add_user_in_group]

  node.add_user_in_group.each do |u, g|

    add_user_in_group u do
      group g
    end

  end
end