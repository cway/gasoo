#encoding: utf-8
#author cway 2013-07-10

class Eventrule < ActiveRecord::Base
   #attr_accessible  :parent_rule_id ,:name, :description, :from_date, :end_date, :is_active
   attr_accessor :products
   self.table_name = "eventrule"
   validates :name, :from_date, :end_date, :presence => true
end
