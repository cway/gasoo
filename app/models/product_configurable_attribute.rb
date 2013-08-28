#encoding: utf-8
#author cway 2013-08-12

class ProductConfigurableAttribute < ActiveRecord::Base
  #attr_accessible :product_configurable_attribute_id, :product_id, :attribute_id, :sort
  self.table_name = "product_configurable_attribute"
end
