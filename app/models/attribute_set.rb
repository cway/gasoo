#encoding: utf-8
#author cway 2013-07-09

class AttributeSet < ActiveRecord::Base
  
  self.table_name          = "eav_attribute_set"
  validates :attribute_set_name, :entity_type_id, :presence => true
  belongs_to( :eav_entity_type, :class_name => "EntityType", :foreign_key => 'entity_type_id' )
  
  #get category index view data
  def self.get_index_data
    attribute_sets         = self.joins( :eav_entity_type )#self.find_by_sql("select `eav_attribute_set`.*, `eav_entity_type`.entity_type_code from eav_attribute_set left join eav_entity_type on eav_entity_type.entity_type_id = eav_attribute_set.entity_type_id;")
  end

  def self.all_with_primary_key
    attribute_sets         =  self.all
    attribute_sets_list    =  Hash.new
    attribute_sets.each do |attribute_set_info|
      attribute_sets_list[attribute_set_info.attribute_set_id] = attribute_set_info.attribute_set_name
    end 
    attribute_sets_list 
  end

end