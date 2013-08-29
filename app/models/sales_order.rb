#encoding: utf-8
#author cway 2013-07-11

class SalesOrder < ActiveRecord::Base
  attr_accessible :entity_id, :status, :state, :customer_id, :grand_total, :created_at
  self.table_name = "sales_order"
end
