
if node[:additional_packages]

  node.additional_packages.each do |p|
    package p
  end

end

if node.lsb.codename == 'stretch' && node[:stretch_additional_packages]
  node.stretch_additional_packages.each do |p|
    package p
  end
elsif node[:default_additional_packages]
  node.default_additional_packages.each do |p|
    package p
  end
end
