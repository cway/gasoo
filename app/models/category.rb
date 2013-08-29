#encoding: utf-8
#author cway 2013-07-09

class Category < ActiveRecord::Base
  #attr_accessible :entity_id, :entity_type_id, :parent_id, :attribute_set_id, :path, :level, :children_count, :created_at, :updated_at
  self.table_name               = "category_entity"
  validates :entity_type_id, :attribute_set_id, :presence => true
 
  #get category index view data
  def self.get_index_data
    name_attribute_id           = self.get_attribute_id( 'name' )
    categories                  = Category.find_by_sql( "select category_entity.*, category_entity_varchar.value as name from category_entity left join category_entity_varchar on category_entity.entity_id = category_entity_varchar.entity_id and category_entity_varchar.attribute_id = #{name_attribute_id};" )
    return categories
  end
 
  def self.get_category_attributes_value( category_id, attribute_ids, data_type )
    if attribute_ids.class     != Array
      attribute_ids             = [attribute_ids]
    end 
    data                        = self.find_by_sql("select * from category_entity_#{data_type} where entity_id = #{category_id} and attribute_id in ( #{attribute_ids.join(',')} )")
    unless data
      data                      = Array.new
    end
    return data
  end
  
  def self.all_by_id_index
    categories                  =  self.get_index_data 
    category_lsit               =  Hash.new
    categories.each do |category|
      category_lsit[category.entity_id] = category.name
    end
    return category_lsit
  end

  def self.all_with_name
    name_attribute_id           = self.get_attribute_id( 'name' )
    categories                  = self.find_by_sql("select category_entity.entity_id, category_entity_varchar.value as name from category_entity left join category_entity_varchar on category_entity.entity_id = category_entity_varchar.entity_id where category_entity_varchar.attribute_id = #{name_attribute_id}")
  end
 
  def self.all_with_name_without_children( category_id )
    name_attribute_id           = self.get_attribute_id( 'name' )
    children                    = self.get_children( category_id )
    children.push( category_id )
    categories                  = self.find_by_sql("select category_entity.entity_id, category_entity_varchar.value as name from category_entity left join category_entity_varchar on category_entity.entity_id = category_entity_varchar.entity_id where category_entity_varchar.attribute_id = #{name_attribute_id} and category_entity.entity_id not in ( #{children.join(',')} )")
    return categories
  end
  
  def self.get_categories_name( category_ids )
    if category_ids.class      != Array
      category_ids              = [category_ids]
    end
    name_attribute_id           = get_attribute_id( 'name' )
    data                        = CategoryEntityVarchar.select("entity_id, value").where( {attribute_id: => name_attribute_id, entity_id: category_ids} ) #self.find_by_sql("select entity_id, value from category_entity_varchar where attribute_id = #{name_attribute_id} and entity_id in ( #{category_ids.join(',')} )")
    categories_name_list        = Hash.new
    data.each do |category|
      categories_name_list[category.entity_id] = category.value
    end
    return categories_name_list
  end

  def self.get_category_info( category_id )
    category                    = self.find( category_id )
    name_attribute              = self.find_by_sql("select * from eav_attribute where `attribute_code` = 'name' and `entity_type_id` = #{ApplicationController::CATEGORY_TYPE_ID} limit 1")
    description_attribute       = self.find_by_sql("select * from eav_attribute where `attribute_code` = 'description' and `entity_type_id` = #{ApplicationController::CATEGORY_TYPE_ID} limit 1")
    category_name               = self.get_category_attributes_value( category_id, name_attribute[0]['attribute_id'], name_attribute[0]['backend_type'] )
    category_description        = self.get_category_attributes_value( category_id, description_attribute[0]['attribute_id'], description_attribute[0]['backend_type'] )
    name                        = ""
    description                 = ""
    unless category_name.empty?
      name                      = category_name[0]['value']
    end

    unless category_description.empty?
      description               = category_description[0]['value']
    end 
    
    category[:name]             = name
    category[:description]      = description
    return category
  end

  def self.get_attribute_id( attribute_code )
      attribute_id              = -1
      attribute                 = EavAttribute.select("attribute_id").where( {attribute_code: attribute_code, entity_type_id: ApplicationController::CATEGORY_TYPE_ID} ).first
      if attribute 
        attribute_id            = attribute['attribute_id'];
      end

      return attribute_id
  end

  def self.update_level( category_id, category_level, category_path )
    category_children           = self.find(:all, :conditions => { :parent_id => category_id.to_i })
    unless category_children.empty?
      category_children.each do | child_category |
        next_level              = category_level + 1
        next_path               = category_path.to_s + "/" + category_id.to_s
        self.update_level( child_category.entity_id, next_level, next_path )
      end
    end

    begin
      category                  = self.find( category_id )
      category.update_attribute( 'level', category_level) 
      category.update_attribute( 'path',  category_path) 
    rescue => err
      raise err 
    end
  end

  def self.get_children( category_id )
    category_children           = self.find(:all, :conditions => { :parent_id => category_id.to_i })
    children                    = Array.new
    unless category_children.empty?
      category_children.each do | child_category |
        children.push( child_category.entity_id  )
        children               += self.get_children( child_category.entity_id )
      end
    end
    return children
  end
end
