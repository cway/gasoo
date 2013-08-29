#encoding: utf-8
#author cway 2013-08-18

class EventProductChildren < ActiveRecord::Base
  #attr_accessible :parent_event_product_id, :product_id, :rule_price, :normal_price, :qty
  self.table_name  =  "event_product_children"


  def self.get_event_product_children( parent_event_product_id )
  	products                       = Array.new
    event_products                 = self.where( {parent_event_product_id: parent_event_product_id} )
    event_products.each do | event_product |
      product                      = Hash.new
      product_attributes           = event_product.instance_variable_get( "@attributes" )

      product_attributes.each do | attribute, value |
        product[attribute]         = value
      end
      products                    << product
    end
    products 
  end 
end
