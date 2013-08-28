#encoding: utf-8
#author cway 2013-07-09

class EntityAttribute < ActiveRecord::Base
  self.table_name = "eav_entity_attribute"
  
  def self.clone_parent_attributes( attribute_set, parent_group_attributes )
    values        =  Array.new
    parent_group_attributes.each do |attribute|
      entity_attribute = {
                           :entity_type_id     => attribute.entity_type_id,
                           :attribute_set_id   => attribute_set.attribute_set_id,
                           :attribute_group_id => attribute.attribute_group_id,
                           :attribute_id       => attribute.attribute_id,
                           :sort               => attribute.sort
                         }
      values  <<  entity_attribute
    end 
    self.create( values )
  end
  
  def self.insert_attributes( group_list, entity_type_id, attribute_set_id )
    values                          =   Array.new 
    group_list.each do |group_info|
      if group_info["attr"]["rel"]  == "user_define_group"
        group_id                    = AttributeGroup.insert_group( attribute_set_id, group_info['data'] )

        if group_id                != -1
          group_info["attr"]["id"]  = group_id
        else
          next
        end
      end    
  
      if group_info.has_key? "children"
        group_info["children"].each do |attribute_info|
          entity_attribute          = {
                                        :entity_type_id     => entity_type_id,
                                        :attribute_set_id   => attribute_set_id,
                                        :attribute_group_id => group_info['attr']['id'],
                                        :attribute_id       => attribute_info['attr']['id']
                                      }
          values   <<  entity_attribute
        end
      end
    end
    self.create( values )
  end
  
end
