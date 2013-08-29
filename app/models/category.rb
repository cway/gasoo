#encoding: utf-8
#author cway 2013-07-09

class Category < ActiveRecord::Base
  attr_accessor :category_attributes
  #attr_accessible :entity_id, :entity_type_id, :parent_id, :attribute_set_id, :path, :level, :children_count, :created_at, :updated_at
  self.table_name               = "category_entity"
  validates :entity_type_id, :attribute_set_id, :presence => true
 
  #get category index view data
  def self.get_index_data
    name_attribute_id           = get_attribute_id( 'name' )
    find_by_sql( "select category_entity.*, category_entity_varchar.value as name from category_entity left join category_entity_varchar on category_entity.entity_id = category_entity_varchar.entity_id and category_entity_varchar.attribute_id = #{name_attribute_id};" )
  end
 
  def self.get_category_attributes_value( category_id, attribute_ids, data_type )
    if attribute_ids.class     != Array
      attribute_ids             = [attribute_ids]
    end

    modelEntity                 = nil
    case data_type
      when "varchar"
        modelEntity             = CategoryEntityVarchar
      when "decimal"            
        modelEntity             = CategoryEntityDecimal
      when "int"
        modelEntity             = CategoryEntityInt
      when "media_gallery"
        modelEntity             = CategoryEntityMediaGallery
      when "text"
        modelEntity             = CategoryEntityText
    end

    data                        = modelEntity.where( {entity_id: category_id, attribute_id: attribute_ids} )
    #data                        = self.find_by_sql("select * from category_entity_#{data_type} where entity_id = #{category_id} and attribute_id in ( #{attribute_ids.join(',')} )")
    unless data
      data                      = Array.new
    end
    data
  end
  
  def self.all_by_id_index
    categories                  =  get_index_data 
    category_list               =  Hash.new
    categories.each do |category|
      category_list[category.entity_id] = category.name
    end
    category_list
  end

  def self.all_with_name
    name_attribute_id           = get_attribute_id( 'name' )
    categories                  = find_by_sql("select category_entity.entity_id, category_entity_varchar.value as name from category_entity left join category_entity_varchar on category_entity.entity_id = category_entity_varchar.entity_id where category_entity_varchar.attribute_id = #{name_attribute_id}")
  end
 
  def self.all_with_name_without_children( category_id )
    name_attribute_id           = get_attribute_id( 'name' )
    children                    = get_children( category_id )
    children.push( category_id )
 
    self.find_by_sql("select category_entity.entity_id, category_entity_varchar.value as name from category_entity left join category_entity_varchar on category_entity.entity_id = category_entity_varchar.entity_id where category_entity_varchar.attribute_id = #{name_attribute_id} and category_entity.entity_id not in ( #{children.join(',')} )")
  end
  
  def self.get_categories_name( category_ids )
    if category_ids.class      != Array
      category_ids              = [category_ids]
    end
    name_attribute_id           = get_attribute_id( 'name' )
    data                        = CategoryEntityVarchar.select("entity_id, value").where( {attribute_id: name_attribute_id, entity_id: category_ids} ) #self.find_by_sql("select entity_id, value from category_entity_varchar where attribute_id = #{name_attribute_id} and entity_id in ( #{category_ids.join(',')} )")
    categories_name_list        = Hash.new
    data.each do |category|
      categories_name_list[category.entity_id] = category.value
    end
    return categories_name_list
  end

  def self.get_category_info( category_id )
    category                    = self.where( {entity_id: category_id} ).first
    name_attribute              = EavAttribute.select("attribute_id, backend_type").where( {attribute_code: 'name', entity_type_id: ApplicationController::CATEGORY_TYPE_ID} ).first
    description_attribute       = EavAttribute.select("attribute_id, backend_type").where( {attribute_code: 'description', entity_type_id: ApplicationController::CATEGORY_TYPE_ID} ).first
    category_name               = get_category_attributes_value( category_id, name_attribute.attribute_id, name_attribute.backend_type )
    category_description        = get_category_attributes_value( category_id, description_attribute.attribute_id, description_attribute.backend_type )
    name                        = ""
    description                 = ""
    unless category_name.empty?
      name                      = category_name[0].value
    end

    unless category_description.empty?
      description               = category_description[0].value
    end 

    category.category_attributes                       = Hash.new
    category.category_attributes['name']               = name
    category.category_attributes['description']        = description
    category
  end

  def self.get_attribute_id( attribute_code )
      attribute_id              = -1
      attribute                 = EavAttribute.select("attribute_id").where( {attribute_code: attribute_code, entity_type_id: ApplicationController::CATEGORY_TYPE_ID} ).first
      if attribute 
        attribute_id            = attribute['attribute_id'];
      end

      return attribute_id
  end

  def self.update_category( category, params )
    name_attribute_id                          = get_attribute_id("name")
    description_attribute_id                   = get_attribute_id("description")
    category_params                            = params[:category]
    category_params["entity_type_id"]          = ApplicationController::CATEGORY_TYPE_ID
    parent_id                                  = category_params["parent_id"].to_i
    
    if parent_id != 0
      begin
        parent_category                        = self.find( parent_id )
      rescue
        parent_category                        = nil
      end
      category_params['parnet_id']             = parent_id
      category_params['level']                 = parent_category.level + 1
    else
      category_params['parent_id']             = 0
      category_params['level']                 = 1 
    end 
   
    begin
     self.transaction do 
       if parent_category
         update_level( category.entity_id, category_params['level'], parent_category )
         category_params["path"]               = parent_category.path + "/" + category.entity_id.to_s
       else
         update_level( category.entity_id, category_params['level'], '' )
         category_params["path"]               = category.entity_id.to_s
       end 

       if category_params['parnet_id']        != category.parent_id
         if parent_category
           parent_category.children_count     += 1
           parent_category.save
         end

         begin
           old_parent_category                 = Category.find( category.parent_id )
         rescue
           old_parent_category                 = nil
         end 

         if old_parent_category
           old_parent_category.children_count -= 1
           old_parent_category.save
         end
       end
      
       category.update_attributes( { :parent_id => category_params['parent_id'], :path => category_params['path'], :level => category_params['level'], :updated_at => DateTime.now } )
       upsert_category_attribute( name_attribute_id, category.entity_id, params[:category][:name], 'varchar' )
       upsert_category_attribute( description_attribute_id, category.entity_id, params[:category][:description], 'text' )
     end 
  
    rescue => err
      raise err.message
    end 
  end


  def self.upsert_category_attribute( attribute_id, entity_id, value, backend_type )
    attribute_params                       = Hash.new
    attribute_params["attribute_id"]       = attribute_id
    attribute_params["entity_id"]          = entity_id
    attribute_params["entity_type_id"]     = ApplicationController::CATEGORY_TYPE_ID
    attribute_params["value"]              = value


    modelEntity                            = nil
    case backend_type
      when "varchar"
        modelEntity                        = CategoryEntityVarchar
      when "decimal"            
        modelEntity                        = CategoryEntityDecimal
      when "int"
        modelEntity                        = CategoryEntityInt
      when "media_gallery"
        modelEntity                        = CategoryEntityMediaGallery
      when "text"
        modelEntity                        = CategoryEntityText
    end

    entity_option                          = { entity_type_id: ApplicationController::CATEGORY_TYPE_ID, attribute_id: attribute_id, entity_id: entity_id }
    entity_value                           = modelEntity.where( entity_option ).first
    if entity_value
      entity_value.update_attribute( 'value', attribute_params["value"] )
    else
      entity_value                         = modelEntity.new(attribute_params);     
      entity_value.save
    end
  end

  def self.update_level( category_id, category_level, category_path )
    category_children           = self.where( { parent_id: category_id.to_i } )
    unless category_children.empty?
      category_children.each do | child_category |
        next_level              = category_level + 1
        next_path               = category_path.to_s == '' ? category_id.to_s : category_path.to_s + "/" + category_id.to_s
        update_level( child_category.entity_id, next_level, next_path )
      end
    end

    begin
      category                  = self.where( {entity_id: category_id} ).first
      category.update_attribute( 'level', category_level) 
      category.update_attribute( 'path',  category_path) 
    rescue => err
      raise err 
    end
  end

  def self.get_children( category_id )
    category_children           = self.where({ parent_id: category_id.to_i })
    children                    = Array.new
    unless category_children.empty?
      category_children.each do | child_category |
        children               << child_category.entity_id
        children               += get_children( child_category.entity_id )
      end
    end
    children
  end

end
