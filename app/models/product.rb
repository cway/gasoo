#encoding: utf-8
#author cway 2013-07-09

class Product < ActiveRecord::Base
  attr_accessor :configurable_attributes, :children, :product_attributes
  #attr_accessible :attribute_set_id, :entity_type_id, :type_id, :sku, :has_options, :required_options
  #attr_writer :price, :qty, :name

  #validates :product_name, :product_description, :price, :presence => true
  #validates :price, :numericality => {:greater_than_or_equal_to => 0.01}
  #validates :picture, :format => {
  #  :with    => %r{\.(gif|jpg|png)$}i,
  #  :message => 'must be a URL for GIF, JPG or PNG image.'
  #}

  self.table_name                 = "product_entity"

  def  self.get_index_attributes
    name                          = EavAttribute.get_attribute( {attribute_code: 'name', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    sku                           = EavAttribute.get_attribute( {attribute_code: 'sku', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    price                         = EavAttribute.get_attribute( {attribute_code: 'price', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    qty                           = EavAttribute.get_attribute( {attribute_code: 'qty', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )


    name_values                   = self.all_attribute_values( name )
    sku_values                    = self.all_attribute_values( sku )
    price_values                  = self.all_attribute_values( price )
    qty_values                    = self.all_attribute_values( qty )

    { :name => name_values, :sku => sku_values, :price => price_values, :qty => qty_values }
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
    children
  end

  def self.get_simple_products_attributes( ids )
    name                           = EavAttribute.get_attribute( {attribute_code: 'name', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    sku                            = EavAttribute.get_attribute( {attribute_code: 'sku', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    price                          = EavAttribute.get_attribute( {attribute_code: 'price', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    qty                            = EavAttribute.get_attribute( {attribute_code: 'qty', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )

    name_values                    = self.get_products_attribute_values( name,  ids )
    sku_values                     = self.get_products_attribute_values( sku,   ids )
    price_values                   = self.get_products_attribute_values( price, ids )
    qty_values                     = self.get_products_attribute_values( qty,   ids )

    { :name => name_values, :sku => sku_values, :price => price_values, :qty => qty_values }
  end

  def self.get_product_attribute_value( product_id, attribute ) 
    value                         = ""
    attribute_entity              = nil
    modelEntity                   = get_value_model attribute.backend_type
    if modelEntity
      attribute_entity            = modelEntity.where(  { entity_id: product_id , attribute_id: attribute.attribute_id} ).first
    end
 
    if attribute_entity
      value                       = attribute_entity.value
    end
    value
  end
 
  def self.get_product_names
    name                          = EavAttribute.get_attribute( {attribute_code: 'name', entity_type_id: ApplicationController::PRODUCT_TYPE_ID} )
    all_attribute_values( name )
  end


  def self.all_attribute_values( attribute )
    values                        = Array.new
    ret_value_list                = Hash.new

    modelEntity                   = get_value_model attribute.backend_type
    if modelEntity
      values                      = modelEntity.where( {attribute_id: attribute.attribute_id} )
    end  

    values.each do |value_info|
      ret_value_list[ value_info.entity_id ] = value_info.value
    end 
    ret_value_list
  end
  
  def self.get_products_attribute_values( attribute, ids )
    conditions			              = Hash.new
    conditions[:attribute_id]     = attribute.attribute_id
    conditions[:entity_id]        = ids

    values                        = Array.new
    ret_value_list                = Hash.new

    modelEntity                   = get_value_model attribute.backend_type
    if modelEntity
      values                      = modelEntity.where( conditions )
    end

    values.each do |value_info|
      ret_value_list[ value_info.entity_id ] = value_info.value
    end

    ret_value_list
  end

  #get attributes for create product
  def self.get_attributes( product_type_id, attribute_set_id)
    EavAttribute.find_by_sql( "select eav_attribute.attribute_code, eav_attribute.attribute_id, eav_attribute.backend_type, eav_attribute.frontend_label, eav_attribute.frontend_input, eav_attribute.is_required, eav_attribute_group.attribute_group_id, eav_attribute_group.attribute_group_name from eav_entity_attribute left join eav_attribute_group on eav_attribute_group.attribute_group_id = eav_entity_attribute.attribute_group_id left join eav_attribute on eav_attribute.attribute_id = eav_entity_attribute.attribute_id  where eav_entity_attribute.entity_type_id = #{product_type_id} and eav_entity_attribute.attribute_set_id = #{attribute_set_id}" )
  end
  
  def self.get_attributes_by_frontend_input( product_type_id, attribute_set_id, frontend_input)
    EavAttribute.find_by_sql( "select eav_attribute.attribute_id, eav_attribute.frontend_label from eav_attribute left join eav_entity_attribute on eav_attribute.attribute_id = eav_entity_attribute.attribute_id and eav_attribute.frontend_input = \"#{frontend_input}\" where eav_entity_attribute.entity_type_id = #{product_type_id} and eav_entity_attribute.attribute_set_id = #{attribute_set_id}" )
  end


  def self.create_product( product_info )
    verify_params product_info, "attribute_set_id"
    verify_params product_info, "type_id"

    attribute_set_id                     =  product_info["attribute_set_id"]
    type_id                              =  product_info["type_id"]
    attribute_list                       =  get_attributes(ApplicationController::PRODUCT_TYPE_ID, attribute_set_id) 
    product_entity                       =  Hash.new 
    product_entity['entity_type_id']     =  ApplicationController::PRODUCT_TYPE_ID
    product_entity['attribute_set_id']   =  attribute_set_id
    product_entity['type_id']            =  type_id
    product_entity['sku']                =  product_info["sku"]
    product                              =  self.new( product_entity )

    self.transaction do
      product.save
      attribute_types_and_value          =  Hash.new
      
      attribute_list.each do |attribute|
        unless attribute_types_and_value.has_key? attribute.backend_type
          attribute_types_and_value[attribute.backend_type]  = Array.new 
        end

        if product_info.has_key? attribute.attribute_code
          if product_info[attribute.attribute_code].class == String and product_info[attribute.attribute_code].empty?
            next
          end
          insert_value                   =  Hash.new
          insert_value['attribute_id']   =  attribute.attribute_id
          insert_value['entity_id']      =  product.entity_id
          insert_value['value']          =  product_info[attribute.attribute_code]
          attribute_types_and_value[attribute.backend_type].push( insert_value )
        end  
      end

      if product_info.has_key? "simple_products_ids"
        add_relation_products product.entity_id, product_info["simple_products_ids"]
      end
      
      attribute_types_and_value.each do | type, type_values |
        insert_entity_values( type_values, type )
      end
     
      categories                        = product_info["categories"]
      unless categories.empty?
        add_categories( product.entity_id, categories )
      end

      if ApplicationController::CONFIGURABLE_PRODUCT_ID == product.type_id.to_i
         add_configurable_attributes product.entity_id, product_info["configurable_attributes"]
      end
    end
    product
  end

  def self.add_relation_products parent_product_id, product_children_ids
    product_children_ids.each do |simple_product_id|
      product_relation_params                 = Hash.new
      product_relation_params["parent_id"]    = parent_product_id
      product_relation_params["child_id"]     = simple_product_id
      product_relation                        = ProductRelation.new( product_relation_params )
      product_relation.save
    end
  end

  def self.add_configurable_attributes(  product_id, configurable_attributes )
    configurable_attributes                   = Array.new
    sort                                      = 0
    configurable_attributes.each do | configurable_attribute_id |
      configurable_attribute                  = Hash.new
      configurable_attribute["product_id"]    = product_id
      configurable_attribute["attribute_id"]  = configurable_attribute_id
      configurable_attribute["sort"]          = sort
      sort                                   += 1
      configurable_attributes.push( configurable_attribute )
    end
    ProductConfigurableAttribute.create( configurable_attributes )
  end
  
  def self.insert_entity_values( type_values, type )
    if type_values.empty?
      return 
    end

    values                        = Array.new
    type_values.each do | value_entity |
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
    
    modelEntity                  = get_value_model type
    if modelEntity
      modelEntity.create( values )
    end 
  end
  
  def self.add_categories( product_id, categories )
    if categories.empty?
      return
    end
    
    values                        = Array.new
    categories.each do | category_id |
      categort_product            = {
                                      :category_id      => category_id,
                                      :product_id       => product_id
                                    }
      values <<  categort_product
    end
    
    CategoryProduct.create( values )
  end

  def self.update_product_attributes( product, attribute_values )
    
    attributes                    = get_update_attributes( attribute_values )  
 
    attributes.each do |attribute|
      if attribute["value"].class =="String" and attribute["value"].empty?
        next
      end

      update_attribute product, attribute
    end  
  end

  private
  def self.get_update_attributes( attribute_values )
    attributes                          = Array.new
    attribute_values.each do |attribute_code, attribute_value|
       attribute_info                   = EavAttribute.where( {attribute_code: attribute_code, entity_type_id: ApplicationController::PRODUCT_TYPE_ID} ).first
       if attribute_info
         attribute_info                 = attribute_info
         
         if attribute_value.class == Array
            attribute_info.value        = attribute_value.to_json
         else
            attribute_info.value        = attribute_value
         end

         attributes.push( attribute_info )
       end 
    end
    attributes
  end

  def self.update_attribute( product, attribute )
      
    modelEntity                 = get_value_model attribute.backend_type
    if modelEntity
      entity_option             = { entity_type_id: ApplicationController::PRODUCT_TYPE_ID, attribute_id: attribute.attribute_id, entity_id: product.entity_id}
       
      #modelEntity.create_with( value: attribute.value ).find_or_create_by( entity_option )
      entity_value              = modelEntity.where( entity_option ).first
      if entity_value
        entity_value.update_attributes( {:value => attribute.value } )
      else
        entity_value            = modelEntity.new( entity_option )
        entity_value.value      = attribute.value
        entity_value.save
      end
    end
  end


  def self.get_value_model( backend_type )
    modelEntity                 = nil
    case backend_type
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
    modelEntity
  end


  def self.verify_params( params, key )
    unless params.has_key? key
      raise ArgumentError, "no params named #{key}" 
    end
  end
  # def method_missing(name, *args)
  #   if name[-1] == '='
  #     nam = name.to_s[0...-1]
  #     if instance_variables.map{|x|x.to_s}.include? "@#{nam.to_s}"
  #       raise "undefined method `#{name}' for #<#{self.class}:#{self.object_id}>"
  #     else
  #       instance_variable_set("@#{nam}", args[0])
  #     end
  #   else
  #     if instance_variables.map{|x|x.to_s}.include? "@#{name.to_s}"
  #       instance_variable_get("@#{name}".to_s)
  #     else
  #       raise "undefined method `#{name}' for #<#{self.class}:#{self.object_id}>"
  #     end
  #   end
  # end

end
