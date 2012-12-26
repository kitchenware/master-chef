
define :php5_cli, {
	:options => {}
	} do

	php5_cli_param = params

		options = {}
		if php5_cli_param[:options]
			php5_cli_param[:options].each do |k, v|
				options[k.is_a?(String) ? k : k.to_s] = v
			end
		end

		config = node.php5.cli_php_ini.to_hash.merge(options)

		template "/etc/php5/cli/php.ini" do
			mode '0644'
			cookbook "php5"
			source "php5.ini.erb"
			variables config
		end

	end