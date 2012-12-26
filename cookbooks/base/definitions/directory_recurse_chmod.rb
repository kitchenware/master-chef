
define :directory_recurse_chmod, {
  :chmod => nil,
  :owner => nil,
  :group => nil,
} do
  
  directory_recurse_chmod_params = params

  raise "Please specify chmod with directory_recurse_chmod" unless directory_recurse_chmod_params[:chmod]

  c = "chmod -R #{directory_recurse_chmod_params[:chmod]} #{directory_recurse_chmod_params[:name]}"
  c += " &&\nchown -R #{directory_recurse_chmod_params[:owner]} #{directory_recurse_chmod_params[:name]}" if directory_recurse_chmod_params[:owner]
  c += " &&\nchgrp -R #{directory_recurse_chmod_params[:group]} #{directory_recurse_chmod_params[:name]}" if directory_recurse_chmod_params[:group]

  execute_version "directory recurse chmod on #{directory_recurse_chmod_params[:name]}" do
    command c
    version "#{directory_recurse_chmod_params[:chmod]}_#{directory_recurse_chmod_params[:owner]}_#{directory_recurse_chmod_params[:group]}"
    file_storage "#{directory_recurse_chmod_params[:name]}/.directory_recurse_chmod"
  end

end