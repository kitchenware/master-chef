
if node[:nodejs_app]

  node.nodejs_app.each do |k, v|

    nodejs_app k do
      user v[:user]
      script v[:script]
      opts v[:opts]
    end

  end

end