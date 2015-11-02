# inspired from https://gist.github.com/mpasternacki/818890

require 'chef/provider/package/apt'
require 'chef/resource/package'

class Chef

  class Provider
    class Package
      class BackportsApt < Chef::Provider::Package::Apt

        def load_current_resource
          super
          status = popen4("apt-cache -o APT::Default-Release=#{main_release}-backports policy #{@new_resource.package_name} && apt-cache -o APT::Default-Release=#{main_release}-backports-sloppy policy #{@new_resource.package_name}") do |pid, stdin, stdout, stderr|
            stdout.each do |line|
              case line
              when /^\s{2}Candidate: (.+)$/
                @candidate_version = $1
              end
            end
          end
        end

        @current_resource
      end

      private

      def main_release
        @main_release ||= %x{lsb_release -cs}.strip
      end

    end
  end

  class Resource
    class BackportsAptPackage < Chef::Resource::Package
      def initialize(name, run_context=nil)
        super
        @resource_name = :backports_apt_package
        @provider = Chef::Provider::Package::BackportsApt
      end
    end
  end

end