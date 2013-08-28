#encoding: utf-8
#author cway 2013-07-09

class EntityType < ActiveRecord::Base
 
  self.table_name  = "eav_entity_type"
  validates :entity_type_id, :entity_type_code, :presence => true
  
  
end
