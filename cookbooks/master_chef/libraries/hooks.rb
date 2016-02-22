
module MasterChefHooks

  def self.add_ok name, code
    MasterChefHooks.add_hook :ok, name, code
  end

  def self.add_failed name, code
    MasterChefHooks.add_hook :failed, name, code
  end

  def self.add_all name, code
    MasterChefHooks.add_hook :all, name, code
  end

  private

  def self.add_hook dir, name, code
    if ! ENV["HOOK_DIR"] || ! Dir.exists?(ENV["HOOK_DIR"])
      Chef::Log.warn("Unable to create hook #{name}")
      return
    end
    file = "#{ENV['HOOK_DIR']}/#{dir}/#{name}"
    File.write(file, code)
    %x{chmod 0755 #{file}}
  end

end