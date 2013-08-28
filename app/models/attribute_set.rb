#encoding: utf-8
#author cway 2013-07-09

class AttributeSet < ActiveRecord::Base
  
  self.table_name          = "eav_attribute_set"
  validates :attribute_set_name, :entity_type_id, :presence => true
  belongs_to( :eav_entity_type, :class_name => "EntityType", :foreign_key => 'entity_type_id' )
  
  #get category index view data
  def self.get_index_data
    attribute_sets         = find_by_sql("select `eav_attribute_set`.*, `eav_entity_type`.entity_type_code from eav_attribute_set left join eav_entity_type on eav_entity_type.entity_type_id = eav_attribute_set.entity_type_id;") #self.includes( :eav_entity_type )
  end

  def self.all_with_primary_key
    attribute_sets         =  self.all
    attribute_sets_list    =  Hash.new
    attribute_sets.each do |attribute_set_info|
      attribute_sets_list[attribute_set_info.attribute_set_id] = attribute_set_info.attribute_set_name
    end 
    attribute_sets_list 
  end

  def self.create_attribute_set( params )
    verify_params params, 'attribute_set'
    verify_params params[:attribute_set], 'parent_set_id'
    verify_params params[:attribute_set], 'entity_type_id'
    verify_params params[:attribute_set], 'attribute_set_name'
     
    attribute_set_params           = {
                                       :entity_type_id        => params[:attribute_set][:entity_type_id],
                                       :attribute_set_name    => params[:attribute_set][:attribute_set_name]
                                     }
   
    attribute_set                  = self.new( attribute_set_params )
    self.transaction do
      if attribute_set.save
        parent_group_attributes    = EntityAttribute.where( attribute_set_id: params[:attribute_set][:parent_set_id] )    
        EntityAttribute.clone_parent_attributes( attribute_set, parent_group_attributes )
      else 
        raise "创建属性集失败"
      end 
    end
    attribute_set
  end

  def self.verify_params( params, key )
    unless params.has_key? key
      raise ArgumentError, "no params named #{key}" 
    end
  end
end
