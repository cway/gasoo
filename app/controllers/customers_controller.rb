#encoding: utf-8
#author cway 2013-07-16

class CustomersController < ApplicationController

   # GET /index
   def index
     @index_data    =   Customer.get_customer_list
   end

   def edit
     render :json => "暂不开放"
   end


   def destory
     render :json => "暂不开放"
   end

end
