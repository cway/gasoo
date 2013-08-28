#encoding: utf-8
#author cway 2013-07-09

class EavAttribute < ActiveRecord::Base
  attr_accessor :value, :options
  self.table_name                              = "eav_attribute"
  validates :attribute_code, :entity_type_id, :presence => true

  def self.get_attribute( conditions )
    attribute                                  = self.where( conditions ).first
    unless attribute
      raise "不存在该属性: " + conditions.to_json
    end
    attribute
  end

  def self.create_eav_attribute( params )
    verify_params params, 'attribute'
    verify_params params[:attribute], 'frontend_input'
    verify_params params, 'options'

    attribute                                = self.new( params[:attribute].permit! )   
    self.transaction do
      attribute.save
      if params[:attribute][:frontend_input] == "select" or params[:attribute][:frontend_input] == "multiselect"
        options                              = params[:options]
	AttributeOption.insert_options( attribute.attribute_id, options )
      end   
    end
    attribute
  end

  def self.update_eav_attribute( params )
    verify_params params, 'id'
    verify_params params, 'attribute'
    verify_params params[:attribute], 'frontend_input'
    verify_params params, 'options'

    attribute                                   =   self.find(params[:id])
    self.transaction do
      attribute.update_attributes( params[:attribute].permit!  )
      if params[:attribute][:frontend_input]   == "select" or params[:attribute][:frontend_input] == "multiselect"
         options                                = params[:options]
         AttributeOption.where(:attribute_id => attribute.attribute_id ).delete_all
         AttributeOption.insert_options( attribute.attribute_id, options )
      end
    end
    attribute
  end 

  def self.verify_params( params, key )
    unless params.has_key? key
  		raise ArgumentError, "no params named #{key}" 
  	end
  end

end
