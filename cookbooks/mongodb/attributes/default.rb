default[:mongodb] = {
  :bind_address => "127.0.0.1",
  :port => 27017,
  :smallfiles => false,
  :profile => 1,
  :slowms => 300, # unused if profile == 0
  :version => "2.2.4",
  :rs => nil, # ReplicaSet Name (nil for none)
}
