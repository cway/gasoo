#encoding: utf-8
#author cway 2013-08-18

class EventProductChildren < ActiveRecord::Base
  #attr_accessible :parent_event_product_id, :product_id, :rule_price, :normal_price, :qty
  self.table_name                  =  "event_product_children"


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

  def update_event_product_children ( event_product_id, event_product_children )
    self.where( :parent_event_product_id => event_product_id ).delete_all
    product_children                                  = Array.new
    event_product_children.each do |child_id, child_product|
      child_product_param                             = Hash.new
      child_product_param['parent_event_product_id']  = event_product_id
      child_product_param['product_id']               = child_product['entity_id']
      child_product_param['rule_price']               = child_product['rule_price']
      child_product_param['normal_price']             = child_product['price']
      child_product_param['qty']                      = child_product['qty']
      product_children << child_product_param
    end
    unless product_children.empty?
      self.create( product_children )
    end
  end
end