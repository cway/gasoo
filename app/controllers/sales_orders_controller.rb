#encoding: utf-8
#author cway 2013-07-11

class SalesOrdersController < ApplicationController
  
  # GET /index
  # GET /index.xml
  def index
    @salesOrders = SalesOrder.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @salesOrders }
    end
  end
  
  # /sales_orders/1
  # /sales_orders/1.xml
  def show
    @salesOrder = SalesOrder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @salesOrder }
    end
  end
end
