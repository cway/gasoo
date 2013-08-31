#encoding: utf-8
#author cway 2013-07-11

class SalesOrdersController < ApplicationController
  
  # GET /index
  def index
    @salesOrders = SalesOrder.all
    status       = SalesOrderStatus.all_with_status_id
    render 'index', :locals => { :status => status }  
  end
  
  # /sales_orders/1 
  def show
    @salesOrder = SalesOrder.find(params[:id])
  end
end
