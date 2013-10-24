
if node[:dbmgr] && node.dbmgr[:files]

  node.dbmgr.files.each do |k, v|

    dbmgr k do
      owner v[:owner] if v[:owner]
      driver v[:driver] if v[:driver]
    end

  end

end