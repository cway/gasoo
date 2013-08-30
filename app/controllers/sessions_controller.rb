#encoding: utf-8
#author cway 2013-08-30

class SessionsController < Devise::SessionsController
  
  def create
  	admin_logger "登录", 1 
  	super
  end

  def destory 
  	admin_logger "登出", 1 
  	super
  end
end
