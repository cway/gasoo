#encoding: utf-8
#author cway 2013-07-11

class SalesOrdersController < ApplicationController
  
  # GET /index
  def index
    @salesOrders  = SalesOrder.all
    status        = SalesOrderStatus.all_with_status_id
    render 'index', :locals => { :status => status }  
  end
  
  # /sales_orders/1 
  def show
    begin
      @salesOrder = SalesOrder.find(params[:id])
    rescue Exception => e
      redirect_to :action => 'index', :notice => '该订单不存在'
      return 
    end 
  end

  def deliver
    begin
      @salesOrder        = SalesOrder.find(params[:id])
      @deliver_companies = ExpressCompany.all
    rescue Exception => e
      redirect_to :action => 'index', :notice => '该订单不存在'
      return 
    end 

  end
end
