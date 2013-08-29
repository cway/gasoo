#encoding: utf-8
#author cway 2013-07-10

class EventProduct < ActiveRecord::Base
   #attr_accessible :event_product_id, :rule_id, :product_id, :from_date, :end_date, :action_operator, :action_amount, :rule_price, :normal_price, :qty
   attr_accessor :name, :price, :children, :entity_id
   self.table_name = "event_product"
   validates :rule_id, :product_id, :presence => true

   def self.get_daily_flashsales
     Eventrule.find_by_sql("select eventrule.rule_id, eventrule.from_date, count(event_product.event_product_id) as cnt from eventrule left join event_product on eventrule.rule_id = event_product.rule_id where eventrule.parent_rule_id = 1 group by event_product.rule_id") 
   end
   
   def self.get_products_name( product_ids )
    if product_ids.class != Array or product_ids.empty?
      return
    end 
   
    name_list                       = EavAttribute.find_by_sql("select product_entity_varchar.value, product_entity_varchar.entity_id from eav_attribute left join product_entity_varchar on product_entity_varchar.attribute_id = eav_attribute.attribute_id  and product_entity_varchar.entity_id in (#{product_ids.join(',')})  where eav_attribute.`attribute_code` = 'name' and eav_attribute.`entity_type_id` = #{ApplicationController::PRODUCT_TYPE_ID}")
    ret_data                        = Hash.new
    name_list.each do | name_info |
      ret_data[name_info.entity_id] = name_info.value
    end
  
    ret_data
   end

   def self.get_products_by_rule_id( rule_id )
     products                       = Array.new
     event_products                 = self.where( { rule_id: rule_id } )
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
