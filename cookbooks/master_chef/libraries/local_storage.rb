
module LocalStorage

  def local_storage_read key
    full_data = read_file
    data = full_data
    keys = key.split(':').map{|s| s.to_sym}
    keys.each do |s|
      data = data[s] if data
    end
    if block_given? && data.nil?
      data = yield
      local_storage_store key, data
    end
    data
  end

  def local_storage_store key, value
    full_data = read_file
    current = full_data
    keys = key.split(':').map{|s| s.to_sym}
    keys.each do |s|
      if s != keys.last
        current[s] = {} unless current[s]
        current = current[s]
      end
    end
    if current[keys.last] != value
      current[keys.last] = value
      save_file full_data
    end
  end

  def extract_config_with_last key
    current = node
    keys = key.split(':').map{|s| s.to_sym}
    keys.each do |s|
      current = current[s] if current
    end
    return symbolize_keys(current.to_hash), keys.last
  end

  def extract_config key
    config, last = extract_config_with_last key
    config
  end

  private

    def symbolize_keys hash
      return nil unless hash
      return hash unless hash.is_a? Hash
      result = {}
      hash.each do |k, v|
        key = k.is_a?(String) ? k.to_sym : k
        result[key] = symbolize_keys v
      end
      result
    end

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