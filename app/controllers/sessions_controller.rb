#encoding: utf-8
#author cway 2013-08-30

class SessionsController < Devise::SessionsController
  
  def create
  	log_entity            = {
                              'log_info'     =>  "登录",
                              'log_time'     =>  Time.now.to_i,
                              'log_admin'    =>  params[:user][:email],
                              'log_ip'       =>  request.remote_ip,
                              'log_status'   =>  1,
                              'controller'   =>  'devise',
                              'action_name'  =>  'sign_in'          
    AdminLog.create( log_entity )
  	super
  end

  def destory 
  	log_entity            = {
                              'log_info'     =>  "登出",
                              'log_time'     =>  Time.now.to_i,
                              'log_admin'    =>  current_user.email,
                              'log_ip'       =>  request.remote_ip,
                              'log_status'   =>  1,
                              'controller'   =>  'devise',
                              'action_name'  =>  'sign_out'          
    AdminLog.create( log_entity )
  	super
  end
end
