
define :deb_curl_dpkg, {
  :url => nil,
} do
  deb_curl_dpkg_params = params

  raise "Please specify url with deb_curl_dpkg" unless deb_curl_dpkg_params[:url]

  short = File.basename(deb_curl_dpkg_params[:url])

  execute_version "install #{deb_curl_dpkg_params[:name]} from #{deb_curl_dpkg_params[:url]}" do
    command "cd /tmp && curl -s -f #{deb_curl_dpkg_params[:url]} -o #{short} && dpkg -i #{short} && rm #{short}"
    environment get_proxy_environment
    version deb_curl_dpkg_params[:url]
    file_storage "/.pkg_#{deb_curl_dpkg_params[:name]}"
  end

end
