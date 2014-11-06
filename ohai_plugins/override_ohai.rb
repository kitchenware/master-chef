
require 'json'

if File.exists? "/opt/master-chef/etc/override_ohai.json"

  override_ohai = JSON.load(File.read("/opt/master-chef/etc/override_ohai.json"))

  if Ohai::VERSION =~ /^6/

    override_ohai.each do |k, v|
      require_plugin k
      get_attribute(k).merge! v
    end

  else

    Ohai.plugin(:OverrideOhai) do

      override_ohai.each do |k, v|
        provides k
        depends k
      end

      collect_data(:default) do
        override_ohai.each do |k, v|
          get_attribute(k).merge! v
        end
      end

    end

  end

end