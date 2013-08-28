#encoding: utf-8
#author cway 2013-07-09

class EavAttribute < ActiveRecord::Base
  include  ParamsFilter
  self.table_name                              = "eav_attribute"
  validates :attribute_code, :entity_type_id, :presence => true

  def self.create_eav_attribute( params )
  	verify_params params, 'attribute'
  	verify_params params[:attribute], 'frontend_input'
  	verify_params params, 'options'

  	self.transaction do
  		attribute                              = self.new(params[:attribute])
	    attribute.save
	    if params[:attribute][:frontend_input] == "select" or params[:attribute][:frontend_input] == "multiselect"
	      options                              = params[:options]
	      AttributeOption.insert_options( attribute.attribute_id, options )
	    end   
	end
	self
  end

  def self.update_eav_attribute( params )
  	verify_params params, 'id'
  	verify_params params, 'attribute'
  	verify_params params[:attribute], 'frontend_input'
  	verify_params params, 'options'

  	 EavAttribute.transaction do
        attribute                                =   EavAttribute.find(params[:id])
        attribute.update_attributes( params[:attribute]  )
        if params[:attribute][:frontend_input]   == "select" or params[:attribute][:frontend_input] == "multiselect"
          options                                = params[:options]
          AttributeOption.where(:attribute_id => attribute.attribute_id ).delete_all
          AttributeOption.insert_options( attribute.attribute_id, options )
        end
     end
     self
  end 

  def verify_params( params, key )
    unless params.has_key? key
  		raise ArgumentError, "no params named #{key}" 
  	end
  end
  
end
