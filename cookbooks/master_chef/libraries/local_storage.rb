
module LocalStorage

  def local_storage_read domain, key
    full_data = read_file
    data = full_data[domain]
    data = data[key] if data
    if block_given? && data.nil?
      data = yield
      full_data[domain] = {} unless full_data[domain]
      full_data[domain][key] = data
      save_file full_data
    end
    data
  end

  def local_storage_read_all domain
    read_file[domain]
  end

  private

    def read_file
      file = node.local_storage.file
      if File.exists? file
        YAML.load(File.read(file))
      else
        {}
      end
    end

    def save_file data
      file = node.local_storage.file
      File.open(file, "w") {|io| io.write(YAML.dump(data))}
      %x{chown #{node.local_storage.owner} #{file} && chmod 0600 #{file}}
    end

end

class Chef::Recipe
  include LocalStorage
end

class Chef::Resource
  include LocalStorage
end

class Chef::Provider
  include LocalStorage
end