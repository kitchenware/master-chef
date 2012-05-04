default[:java][:default_version] = "java-6-sun"
default[:java][:versions] = Dir["#{File.dirname(__FILE__)}/../recipes/java_*.rb"].map{|x| File.basename(x) =~ /^java_(.*).rb$/; $1}