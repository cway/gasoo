#encoding: utf-8
#author cway 2013-07-09

class Product < ActiveRecord::Base
  attr_accessor :configurable_attributes, :children
  #attr_accessible :attribute_set_id, :entity_type_id, :type_id, :sku, :has_options, :required_options
  #attr_writer :price, :qty, :name

  #validates :product_name, :product_description, :price, :presence => true
  #validates :price, :numericality => {:greater_than_or_equal_to => 0.01}
  #validates :picture, :format => {
  #  :with    => %r{\.(gif|jpg|png)$}i,
  #  :message => 'must be a URL for GIF, JPG or PNG image.'
  #}

  self.table_name = "product_entity"

  def  self.get_index_attributes
    name                          = EavAttribute.get_attribute( {attribute_code: 'name', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    sku                           = EavAttribute.get_attribute( {attribute_code: 'sku', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    price                         = EavAttribute.get_attribute( {attribute_code: 'price', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    qty                           = EavAttribute.get_attribute( {attribute_code: 'qty', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )


    name_values                   = self.all_attribute_values( name )
    sku_values                    = self.all_attribute_values( sku )
    price_values                  = self.all_attribute_values( price )
    qty_values                    = self.all_attribute_values( qty )

    return { :name => name_values, :sku => sku_values, :price => price_values, :qty => qty_values }
  end

  def self.get_flashsales_attributes( ids )
    name                          = EavAttribute.get_attribute( {attribute_code: 'name', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    sku                           = EavAttribute.get_attribute( {attribute_code: 'sku', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    price                         = EavAttribute.get_attribute( {attribute_code: 'price', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    qty                           = EavAttribute.get_attribute( {attribute_code: 'qty', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )

  
    name_values                   = self.get_products_attribute_values( name, ids)
    sku_values                    = self.get_products_attribute_values( sku, ids)
    price_values                  = self.get_products_attribute_values( price, ids)
    qty_values                    = self.get_products_attribute_values( qty, ids)

    children                      = Hash.new
    name_values.each do | entity_id, name |
      child                       = Hash.new
      child['name']               = name
      child['sku']                = sku_values[entity_id]
      child['price']              = price_values[entity_id]
      child['qty']                = qty_values[entity_id]
      child['entity_id']          = entity_id
      children[entity_id]         = child
    end
    return children
  end

  def self.get_simple_products_attributes( ids )
    name                           = EavAttribute.get_attribute( {attribute_code: 'name', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    sku                            = EavAttribute.get_attribute( {attribute_code: 'sku', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    price                          = EavAttribute.get_attribute( {attribute_code: 'price', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    qty                            = EavAttribute.get_attribute( {attribute_code: 'qty', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )

    name_values                   = self.get_products_attribute_values( name,  ids )
    sku_values                    = self.get_products_attribute_values( sku,   ids )
    price_values                  = self.get_products_attribute_values( price, ids )
    qty_values                    = self.get_products_attribute_values( qty,   ids )

    return { :name => name_values, :sku => sku_values, :price => price_values, :qty => qty_values }
  end

  def self.get_product_attribute_value( product_id, attribute ) 
    value = ""
    case attribute.backend_type
      when "varchar"
        attribute_entity          = ProductEntityVarchar.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" ) 
      when "int"
        attribute_entity          = ProductEntityInt.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" )
      when "decimal"
        attribute_entity          = ProductEntityDecimal.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" )
      when "text"
        attribute_entity          = ProductEntityText.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" )
      when "media_gallery"
        attribute_entity          = ProductEntityMediaGallery.first( :conditions => { :entity_id => product_id , :attribute_id => attribute.attribute_id}, :select => "value" )
    end
 
    if attribute_entity
      value                       = attribute_entity['value']
    end
    value
  end
 
  def self.get_product_names
    name                          = self.find_by_sql("select * from eav_attribute where `attribute_code` = 'name' and `entity_type_id` = #{ApplicationController::PRODUCT_TYPE_ID} limit 1")
    name_values                   = self.all_attribute_values( name[0] )
    return name_values   
  end


  def self.all_attribute_values( attribute )
    values                        = Array.new
    ret_value_list                = Hash.new
    case attribute.backend_type
      when "varchar"
        values                    = ProductEntityVarchar.find_all_by_attribute_id( attribute.attribute_id ) 
      when "int"
        values                    = ProductEntityInt.find_all_by_attribute_id( attribute.attribute_id )
      when "decimal"
        values                    = ProductEntityDecimal.find_all_by_attribute_id( attribute.attribute_id )
      when "media_gallery"
        values                    = ProductEntityMediaGallery.find_all_by_attribute_id( attribute.attribute_id )
      when "text"
        values                    = ProductEntityText.find_all_by_attribute_id( attribute.attribute_id )
    end

    values.each do |value_info|
      ret_value_list[ value_info.entity_id ] = value_info.value
    end

    return ret_value_list
  end
  
  def self.get_products_attribute_values( attribute, ids )
    conditions			              = Hash.new
    conditions[:attribute_id]     = attribute.attribute_id
    conditions[:entity_id]        = ids

    values                        = Array.new
    ret_value_list                = Hash.new
    case attribute.backend_type
      when "varchar"
        values                    = ProductEntityVarchar.where( conditions )
      when "int"
        values                    = ProductEntityInt.where( conditions )
      when "decimal"
        values                    = ProductEntityDecimal.where( conditions )
      when "media_gallery"
        values                    = ProductEntityMediaGallery.where( conditions )
      when "text"
        values                    = ProductEntityText.where( conditions )
    end

    values.each do |value_info|
      ret_value_list[ value_info.entity_id ] = value_info.value
    end

    return ret_value_list
  end

  #get attributes for create product
  def self.get_attributes( product_type_id, attribute_set_id)
    attribute_list                = self.find_by_sql( "select eav_attribute.attribute_code, eav_attribute.attribute_id, eav_attribute.backend_type, eav_attribute.frontend_label, eav_attribute.frontend_input, eav_attribute.is_required, eav_attribute_group.attribute_group_id, eav_attribute_group.attribute_group_name from eav_entity_attribute left join eav_attribute_group on eav_attribute_group.attribute_group_id = eav_entity_attribute.attribute_group_id left join eav_attribute on eav_attribute.attribute_id = eav_entity_attribute.attribute_id  where eav_entity_attribute.entity_type_id = #{product_type_id} and eav_entity_attribute.attribute_set_id = #{attribute_set_id}" )
    return attribute_list
  end
  
  def self.get_attributes_by_frontend_input( product_type_id, attribute_set_id, frontend_input)
    attribute_list                = self.find_by_sql( "select eav_attribute.attribute_id, eav_attribute.frontend_label from eav_attribute left join eav_entity_attribute on eav_attribute.attribute_id = eav_entity_attribute.attribute_id and eav_attribute.frontend_input = \"#{frontend_input}\" where eav_entity_attribute.entity_type_id = #{product_type_id} and eav_entity_attribute.attribute_set_id = #{attribute_set_id}" )
    return attribute_list
  end
  
  def self.insert_entity_values( type_values, type )
    if type_values.empty?
      return 
    end

    values                        = Array.new
    type_values.each do | value_entity |
      #values << "( #{ApplicationController::PRODUCT_TYPE_ID}, #{value_entity['attribute_id']}, #{value_entity['entity_id']}, #{value_entity['value']} )"
      entity_value                = {
                                      :entity_type_id => ApplicationController::PRODUCT_TYPE_ID,
                                      :attribute_id   => value_entity['attribute_id'],
                                      :entity_id      => value_entity['entity_id'],
                                      :value          => value_entity['value']
                                    }
      if entity_value[:value].class == Array
        entity_value[:value]     = entity_value[:value].to_json
      end
      values.push( entity_value )
    end
    #res                           =  ActiveRecord::Base.connection().insert("INSERT INTO `product_entity_#{type}` (`entity_type_id`, `attribute_id`, `entity_id`, `value`) VALUES #{values.join(',')}") 
    modelEntity                  = nil
    case type
    when "varchar"
      modelEntity                = ProductEntityVarchar
    when "decimal" 
      modelEntity                = ProductEntityDecimal
    when "int"
      modelEntity                = ProductEntityInt
    when "media_gallery"
      modelEntity                = ProductEntityMediaGallery
    when "text"
      modelEntity                = ProductEntityText
    end
    modelEntity.create( values )
    
    return 
  end
  
  def self.add_categories( product_id, categories )
    if categories.empty?
      return
    end
    
    values                        = Array.new
    categories.each do | category_id |
      values << "( #{category_id}, #{product_id} )"
    end
    
    res                           =  ActiveRecord::Base.connection().insert("INSERT INTO `category_product` (`category_id`, `product_id`) VALUES #{values.join(',')}") 
    return res
  end

  def self.update_product_attributes( product, attribute_values )
    attributes                    = Array.new
    attribute_values.each do |attribute_code, attribute_value|
       attribute_info             = self.find_by_sql("select * from eav_attribute where `attribute_code` = \"#{attribute_code}\"")#Attribute.find_by_attribute_code( attribute_code ) 
       if attribute_info
         attribute_info           = attribute_info[0]
         
         if attribute_value.class == Array
            attribute_info["value"]     = attribute_value.to_json
         else
            attribute_info["value"]     = attribute_value
         end

         attributes.push( attribute_info )
       end 
    end 
 
    attributes.each do |attribute|
      if attribute["value"].class =="String" and attribute["value"].empty?
        next
      end

      modelEntity                 = nil
      case attribute.backend_type
        when "varchar"
          modelEntity             = ProductEntityVarchar
        when "decimal"            
          modelEntity             = ProductEntityDecimal
        when "int"
          modelEntity             = ProductEntityInt
        when "media_gallery"
          modelEntity             = ProductEntityMediaGallery
        when "text"
          modelEntity             = ProductEntityText
      end 

      if modelEntity
        entity_option             = {:entity_type_id => ApplicationController::PRODUCT_TYPE_ID, :attribute_id => attribute.attribute_id, :entity_id => product.entity_id}
          entity_value            = modelEntity.first( :conditions => entity_option )
          if entity_value
            entity_value.update_attributes( {:value => attribute["value"] } )
          else
            entity_value          = modelEntity.new( entity_option )
            entity_value["value"] = attribute["value"]
            entity_value.save
          end
      end
    end  
  end

end