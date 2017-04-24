branch = node[:elasticsearch].key?(:branch) ? node[:elasticsearch][:branch] : '2.x'

add_apt_repository 'elasticsearch' do
  url "http://packages.elastic.co/elasticsearch/#{branch}/debian"
  distrib 'stable'
  components ['main']
  key 'D88E42B4'
  key_url 'https://packages.elastic.co/GPG-KEY-elasticsearch'
end
