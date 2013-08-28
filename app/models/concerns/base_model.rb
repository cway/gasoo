#encoding: utf-8
#author cway 2013-08-28

class BaseModel < ActiveRecord::Base

  def self.verify_params( params, key )
    unless params.has_key? key
  		raise ArgumentError, "no params named #{key}" 
  	end
  end

end