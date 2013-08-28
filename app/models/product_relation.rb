#encoding: utf-8
#author cway 2013-08-08

class ProductRelation < ActiveRecord::Base
  #attr_accessible :parent_id, :child_id
  self.table_name = "product_relation"
end
