#encoding: utf-8
#author cway 2013-07-29

class ProductEntityText < ActiveRecord::Base
  #attr_accessible :value_id, :entity_type_id, :attribute_id, :entity_id, :value
  self.table_name = "product_entity_text"
end
