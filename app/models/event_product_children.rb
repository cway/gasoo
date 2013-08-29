#encoding: utf-8
#author cway 2013-08-18

class EventProductChildren < ActiveRecord::Base
  #attr_accessible :parent_event_product_id, :product_id, :rule_price, :normal_price, :qty
  self.table_name  =  "event_product_children"
end
