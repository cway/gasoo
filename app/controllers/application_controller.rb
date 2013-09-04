#encoding: utf-8
#author cway 2013-07-09

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
    conn = Faraday.new(:url => "http://192.168.1.110:12581" ) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      #faraday.adapter  :em_synchrony            # fiber aware http client
    end

    headers['Content-Type']                  = 'application/json' unless headers['Content-Type']
    response                                 = nil
    ret                                      = nil
    if type == "POST" or type == "post"
      response                               = conn.post do |request|
        request.url                          url
        request.headers['Content-Type']      = headers['Content-Type']
        request.body                         = params
      end
    else
      response = conn.get do |request|
        request.url                          url
      end
    end

    if response
      response_body                          = JSON.parse response.body
      if response_body.code != 0
        raise response_body.err_msg
      end
      ret                                    = response_body.data
    else
      raise "请求失败"
    end
    ret
  end

  def verify_required_params( params, required = [] )
    required.each do | required_key |
      unless params.has_key? required_key
        raise ArgumentError, "未定义属性 #{required_key}"  
      end
    end
  end

end