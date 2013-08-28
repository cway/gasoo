#encoding: utf-8
#author cway 2013-07-15

class ProductType < ActiveRecord::Base
  validates       :product_type_name, :presence => true
  self.table_name                          =  "product_type"

  def self.all_with_primary_key
    types                                  =  self.all
    type_list                              =  Hash.new
    types.each do |type_info|
      type_list[type_info.product_type_id] = type_info.product_type_name
    end

    type_list
  end
end
