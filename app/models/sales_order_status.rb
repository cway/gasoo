#encoding: utf-8
#author cway 2013-08-31

class SalesOrderStatus < ActiveRecord::Base
  #attr_accessible :entity_id, :status, :state, :customer_id, :grand_total, :created_at
  self.table_name = "sales_order_status"

  def self.all_with_status_id
    status        = SalesOrderStatus.all
    status_hash   = Hash.new

    status.each do |state|
      status_hash[state.status_id]  =  state.status_label
    end
    status_hash
  end
end
