#encoding: utf-8
#author cway 2013-07-10

class Eventrule < ActiveRecord::Base
   #attr_accessible  :parent_rule_id ,:name, :description, :from_date, :end_date, :is_active
   attr_accessor :products, :product_ids
   self.table_name = "eventrule"
   validates :name, :from_date, :end_date, :presence => true

   def self.create_eventrule( eventrule_info )
   	 verify_params eventrule_info, 'products'
   	 verify_params eventrule_info, 'from_date'
   	 verify_params eventrule_info, 'end_date'

   	 products                                    = eventrule_info['products']
   	 from_date                                   = Time.parse(eventrule_info['from_date']).getlocal()
     end_date                                    = Time.parse(eventrule_info['end_date']).getlocal()
     self.transaction do
	   eventrule_params                          = Hash.new
	   eventrule_params["parent_rule_id"]        = 1
	   eventrule_params["name"]                  = "闪购-" + from_date.strftime("%Y-%m-%d")
	   eventrule_params["description"]           = "杭州大厦-闪购"+ from_date.strftime("%Y-%m-%d")
	   eventrule_params["from_date"]             = from_date.strftime("%Y-%m-%d %H:%M:%S")
	   eventrule_params["end_date"]              = end_date.strftime("%Y-%m-%d %H:%M:%S")
	   eventrule_params["is_active"]             = ApplicationController::ACTIVE
	   eventrule                                 = Eventrule.new( eventrule_params )
	   eventrule.save 
	   products.each do |product|
         EventProduct.create_event_product product, eventrule
       end
	 end
   end

   def self.update_eventrule( eventrule, eventrule_info )
   	 verify_params eventrule_info, 'products'
   	 verify_params eventrule_info, 'from_date'
   	 verify_params eventrule_info, 'end_date'

   	 products                                    = eventrule_info['products']
   	 from_date                                   = Time.parse(eventrule_info['from_date']).getlocal()
     end_date                                    = Time.parse(eventrule_info['end_date']).getlocal()
     self.transaction do
        eventrule["parent_rule_id"]              = 1
        eventrule["name"]                        = "闪购-" + from_date.strftime("%Y-%m-%d")
        eventrule["description"]                 = "杭州大厦闪购-"+ from_date.strftime("%Y-%m-%d")
        eventrule["from_date"]                   = from_date.strftime("%Y-%m-%d %H:%M:%S")
        eventrule["end_date"]                    = end_date.strftime("%Y-%m-%d %H:%M:%S")
        eventrule["is_active"]                   = ApplicationController::ACTIVE
        eventrule.save
        EventProduct.where( :rule_id => eventrule.rule_id ).delete_all
        products.each do |product|
          EventProduct.create_event_product product, eventrule
        end
     end
   end

   def self.verify_params( params, key )
    unless params.has_key? key
      raise ArgumentError, "no params named #{key}" 
    end
  end
end
