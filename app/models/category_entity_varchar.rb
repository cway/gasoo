#encoding: utf-8
#author cway 2013-07-20

class CategoryEntityVarchar < ActiveRecord::Base
  #attr_accessible :value_id, :entity_type_id, :attribute_id, :entity_id, :value
  self.table_name = "category_entity_varchar"
end
