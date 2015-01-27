
execute_version "update pip" do
  command "pip install --upgrade pip"
  environment get_proxy_environment
  version "1"
  file_storage "/.pip_updated"
end

execute_version "upgrade setuptools" do
  command "pip install setuptools --no-use-wheel --upgrade"
  environment get_proxy_environment
  version "1"
  file_storage "/.pip_setupstools"
end
