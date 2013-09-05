#encoding: utf-8
#author cway 2013-07-09
require 'internal_service'

module RemovableConstants  
  
  def def_if_not_defined(const, value)  
    self.class.const_set(const, value) unless self.class.const_defined?(const)  
  end  
  
  def redef_without_warning(const, value)  
    self.class.send(:remove_const, const) if self.class.const_defined?(const)  
    self.class.const_set(const, value)  
  end  
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  attr_accessor :internal_service
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  
  PRODUCT_TYPE_ID         = 1
  CATEGORY_TYPE_ID        = 2
  CUSTOMER_TYPE_ID        = 3
  CONFIGURABLE_PRODUCT_ID = 2
  SIMPLE_PRODUCT_ID       = 3
  ACTIVE                  = 1

  CATEGORY_DEFAULT_SET_ID = 2

  SUCCESS                 = 1
  FAILED                  = 0

  REQUEST_SUCCESS         = 200

  ATTRIBUTE_INPUT_TYPE    = { 
                               "text"        => "文本框(单行)",
                               "password"    => "密码",
                               "textarea"    => "文本框(多行)",
                               "date"        => "日期",
                               "boolean"     => "是/否",
                               "multiselect" => "多选",
                               "select"      => "单选",
                               "price"       => "价格",
                               "image"       => "图片"
                            }
 
  ATTRIBUTE_BACKEND_TYPE  = {
                               "tinyint"     => "tinyint",
                               "smallint"    => "smallint",
                               "mediumint"   => "mediumint",
                               "int"         => "int",
                               "char"        => "char",
                               "varchar"     => "varchar",
                               "text"        => "text",
                               "mediumtext"  => "mediumtext",
                               "timestamp"   => "timestamp",
                               "datetime"    => "datetime"
                            }

  YES_NO_OPTION           = {
                               0             => "否",
                               1             => "是"
                            }

  ORDER_STATUS            = {
                               'delivering'  => 9
                            }

  def initialize
    @internal_service     = InternalService.new
    super
  end

  def model_to_hash( model_entity )
    model_entity.attributes
  end

  def admin_logger( log_info, status )
    log_entity            = {
                              'log_info'     =>  log_info,
                              'log_time'     =>  Time.now.to_i,
                              'log_admin'    =>  current_user.email,
                              'log_ip'       =>  request.remote_ip,
                              'log_status'   =>  status,
                              'controller'   =>  controller_name,
                              'action'       =>  action_name   
                            }       
    AdminLog.create( log_entity )
  end

  def internal_api( url = '', params = {}, type = 'POST', headers = {} )
    response             = nil
    begin
      case type
        when 'POST'
          response       = internal_service.post( url, params, headers )
        when 'PUT'
          response       = internal_service.put( url, params, headers )
        when 'DELTET'
          response       = internal_service.delete( url, params )
        when 'GET' 
          response       = internal_service.get( url, params )
      end
    rescue Exception => e
      raise "请求失败"
    end 
    unless response
      raise "请求失败"
    end
    response
  end

  def verify_required_params( params, required = [] )
    required.each do | required_key |
      unless params.has_key? required_key
        raise "未定义属性 #{required_key}"  
      end
    end
  end

end