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

  def model_to_hash( model_entity )
    model_entity.attributes
  end
end