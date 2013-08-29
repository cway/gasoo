#encoding: utf-8
#author cway 2013-07-16

class Customer < ActiveRecord::Base
  self.table_name = "customer_entity"
  
  def self.get_customer_list
    default_attribute_set_id = 3
    default_type_id          = 3
    default_group_id         = 4
    customer_attributes      = self.find_by_sql("select eav_attribute.attribute_id, eav_attribute.backend_type, eav_attribute.frontend_label, eav_attribute.frontend_class from eav_entity_attribute left join eav_attribute on eav_attribute.attribute_id = eav_entity_attribute.attribute_id where eav_entity_attribute.attribute_group_id = #{default_group_id}")
    customers                = self.find_by_sql("select entity_id, email from customer_entity")
       

    backend_type_list        = Hash.new
    customers_info           = Array.new 
    customer_attributes.each do |customer_attribute|
      unless backend_type_list.has_key? customer_attribute.backend_type
        backend_type_list[customer_attribute.backend_type]                       =  Array.new
      end
       
      customers.each do | customer |
        customer_info                                                             = Hash.new
        customer_info['entity_id']                                                = customer.entity_id
        customer_info['email']                                                    = customer.email
        customer_info[customer_attribute.attribute_id]                            = Hash.new
        if customer_attribute.frontend_class
          customer_info[customer_attribute.attribute_id]["func"]                  = customer_attribute.frontend_class
        end
        customer_info[customer_attribute.attribute_id]["name"]                    = customer_attribute.frontend_label  
        customers_info.push( customer_info )
       end  
      backend_type_list[customer_attribute.backend_type].push( customer_attribute.attribute_id )
    end
  
    customers_list           = Hash.new 
    customers_info.each do |customers|
      customers_list[customers['entity_id']] = customers 
    end
 
    backend_type_list.each do |type, attribute_ids|
      attributes_values      = self.get_customers_attributes_value( attribute_ids, type )
       
      attributes_values.each do | attribute_value |
        if customers_list[attribute_value.entity_id][attribute_value.attribute_id]
          customers_list[attribute_value.entity_id][attribute_value.attribute_id]["value"] = attribute_value.value
        end
      end 
    end
   
    ret_data                = Hash.new
    ret_data["attributes"]  = customer_attributes 
    ret_data["customers"]   = customers_list
    return ret_data
  end
  
  def self.get_customers_attributes_value( attribute_ids, data_type )
    if attribute_ids.class != Array
      attribute_ids         = [attribute_ids]
    end
    data                    =  Array.new
    case data_type
      when "varchar"
        data   = self.find_by_sql("select customer_entity.entity_id, customer_entity_varchar.attribute_id , customer_entity_varchar.value from customer_entity left join customer_entity_varchar on customer_entity.entity_id = customer_entity_varchar.entity_id  where  attribute_id in ( #{attribute_ids.join(',')} )")
      when "datetime"
        data   = self.find_by_sql("select customer_entity.entity_id, customer_entity_datetime.attribute_id , customer_entity_datetime.value from customer_entity left join customer_entity_datetime on customer_entity.entity_id = customer_entity_datetime.entity_id  where  attribute_id in ( #{attribute_ids.join(',')} )")
      when "int" 
        data   = self.find_by_sql("select customer_entity.entity_id, customer_entity_int.attribute_id , customer_entity_int.value from customer_entity left join customer_entity_int on customer_entity.entity_id = customer_entity_int.entity_id  where  attribute_id in ( #{attribute_ids.join(',')} )")
    end
    return data
  end
 
  def self.get_customer_attributes_value( customer_id, attribute_ids, data_type ) 
    if attribute_ids.class != Array
      attribute_ids         = [attribute_ids]
    end
    data                    =  Array.new
    case data_type
      when "varchar"
        data   = self.find_by_sql("select * from customer_entity_varchar where entity_id = #{customer_id} and attribute_id in ( #{attribute_ids.join(',')} )")
    end
    
    return data
  end
  
end
