
module AptHelper

  def self.backports_version package
    %x{apt-get changelog -s -t $(lsb_release -sc)-backports #{package}  | grep $(lsb_release -sc)-backports | head -n1}.match(/\(([^\)]+)\)/)[1]
  end

  def self.not_installed package
    yield if %x{dpkg -l | grep " #{package} "}.strip.empty?
  end

end