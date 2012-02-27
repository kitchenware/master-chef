
if node[:additional_packages]

  node.additional_packages.each do |p|
    package p
  end

end


if node[:additional_ppas]

  node.additional_ppas.each do |k, v|
    base_ppa k do
      url v
    end
  end
  
end