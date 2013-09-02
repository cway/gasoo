#encoding: utf-8
#author cway 2013-07-18

module SalesOrdersHelper 

  def get_shipping_address( shipping_id ) 
    shipping_address      =    SalesOrderAddress.where({entity_id: shipping_id}).first
    if shipping_address
      "详细地址: " << shipping_address.province << " " << shipping_address.city << " " << shipping_address.district << " " << shipping_address.street << ", 收件人: "  << shipping_address.addressee << ", 电话: " << shipping_address.telephone << ", 邮编: " << shipping_address.postcode
    else
      "收货地址不存在"
    end
  end
end
