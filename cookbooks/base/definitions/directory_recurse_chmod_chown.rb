
define :directory_recurse_chmod_chown, {
  :chmod => nil,
  :owner => nil,
  :group => nil,
} do
  
  directory_recurse_chmod_chown_params = params

  c = []
  c << "chmod -R #{directory_recurse_chmod_chown_params[:chmod]} #{directory_recurse_chmod_chown_params[:name]}" if directory_recurse_chmod_chown_params[:chmod]
  c << "chown -R #{directory_recurse_chmod_chown_params[:owner]} #{directory_recurse_chmod_chown_params[:name]}" if directory_recurse_chmod_chown_params[:owner]
  c << "chgrp -R #{directory_recurse_chmod_chown_params[:group]} #{directory_recurse_chmod_chown_params[:name]}" if directory_recurse_chmod_chown_params[:group]

  execute_version "directory recurse chmod on #{directory_recurse_chmod_chown_params[:name]}" do
    command c.join(" &&\n")
    version "#{directory_recurse_chmod_chown_params[:chmod]}_#{directory_recurse_chmod_chown_params[:owner]}_#{directory_recurse_chmod_chown_params[:group]}"
    file_storage "#{directory_recurse_chmod_chown_params[:name]}/.directory_recurse_chmod_chown"
  end

end