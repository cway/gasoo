#encoding: utf-8
#author cway 2013-07-09

class AttributeGroup < ActiveRecord::Base

  self.table_name           = "eav_attribute_group"
  
  def self.group_inner_attributes( attribute_set_id )
    attributes_records      = find_by_sql( "select eav_entity_attribute.attribute_id, eav_attribute.attribute_code, eav_attribute.is_required, eav_attribute_group.attribute_group_id, eav_attribute_group.attribute_group_name from eav_entity_attribute LEFT JOIN eav_attribute_group  on `eav_entity_attribute`.attribute_group_id = eav_attribute_group.attribute_group_id LEFT join eav_attribute on eav_attribute.attribute_id = eav_entity_attribute.attribute_id  where eav_entity_attribute.attribute_set_id = #{attribute_set_id}" )
  end
  
  def self.out_of_group_attributes( entity_type_id, attribute_set_id )
    attributes_records      = find_by_sql( "select * from eav_attribute WHERE  entity_type_id = #{entity_type_id} AND eav_attribute.attribute_id not in (SELECT attribute_id from eav_entity_attribute where eav_entity_attribute.attribute_set_id = #{attribute_set_id} )" )
  end
  
  def self.insert_group( attribute_set_id, group_name, sort = 0 )
    group_data              = {:attribute_set_id => attribute_set_id, :attribute_group_name => group_name, :sort => sort } 
    group_entity            = self.new( group_data )
    result                  = group_entity.save  
    
    return result ? group_entity.attribute_group_id : -1
  end

end
