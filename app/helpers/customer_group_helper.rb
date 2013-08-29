#encoding: utf-8
#author cway 2013-07-18

module CustomerGroupHelper
  
  def get_customer_group_code( group_id = 1 )
    group_code   = ""
    group_info   = CustomerGroup.find( group_id )
    if group_info
      group_code = group_info["customer_group_code"]
    end
    
    group_code
  end

end
