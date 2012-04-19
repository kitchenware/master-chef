
module PasswordGenerator

  def generate file, len
    unless File.exists? file
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      File.open(file, 'w') {|io| io.write(newpass)}
      %x{chmod 0600 #{file}}
    end
    File.read(file)
  end

  module_function :generate

end