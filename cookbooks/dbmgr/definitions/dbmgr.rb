
define :dbmgr, {
  :mode => '0755',
  :owner => nil,
  :group => nil,
  :driver => 'mysql',
} do

  dbmgr_params = params

  template dbmgr_params[:name] do
    cookbook 'dbmgr'
    owner dbmgr_params[:owner] if dbmgr_params[:owner]
    group dbmgr_params[:group] if dbmgr_params[:group]
    mode dbmgr_params[:mode]
    variables :driver => dbmgr_params[:driver]
    source 'dbmgr.sh.erb'
  end

end