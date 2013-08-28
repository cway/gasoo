#encoding: utf-8
#author cway 2013-07-22

class AttributeOption < ActiveRecord::Base
  self.table_name        = "eav_attribute_option"
  
  def self.insert_options( attribute_id, options )
    if options.class    != Array
      options            = [options]
    end

    values               =  Array.new
    options.each_with_index do |option, index| 
      attribute_option   =  { :attribute_id => attribute_id, :value => option, :sort => index }
      values << attribute_option
    end
    self.create( values )
  end

end
