
require 'json'

if File.exists? "/opt/master-chef/etc/override_ohai.json"

  override_ohai = JSON.load(File.read("/opt/master-chef/etc/override_ohai.json"))

  override_ohai.each do |k, v|
    require_plugin k
    get_attribute(k).merge! v
  end

end