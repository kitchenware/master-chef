

class Hash
  def deep_merge(hash)
    target = dup
    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end
      target.update(hash) { |key, *values| values.flatten.uniq }
    end
    target
  end
end