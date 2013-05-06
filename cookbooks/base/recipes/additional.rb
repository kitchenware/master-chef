
if node[:additional_packages]

  node.additional_packages.each do |p|
    package p
  end

end
