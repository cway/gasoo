#encoding: utf-8
#author cway 2013-07-11

class SalesOrdersController < ApplicationController
  
  # GET /index
  def index
    @salesOrders          = SalesOrder.all
    status                = SalesOrderStatus.all_with_status_id
    render 'index', :locals => { :status => status }  
  end
  
  # /sales_orders/1 
  def show
    begin
      @salesOrder         = SalesOrder.find(params[:id])
    rescue Exception => err
      redirect_to :action => 'index', :notice => '该订单不存在'
      return 
    end 
  end

  def shipping
    begin
      @salesOrder        = SalesOrder.find(params[:id])
      @deliver_companies = ExpressCompany.all
    rescue Exception => err
      redirect_to :action => 'index', :notice => '该订单不存在'
      return 
    end 
  end

  def create_shipping
    verify_required_params params, ['order_id', 'address_id', 'deliver_company', 'shipping_id']
    order_id                                 = params[:order_id]
    address_id                               = params[:address_id]
    deliver_company                          = params[:deliver_company]
    express_id                               = params[:express_id]

    order_address                            = SalesOrderAddress.select("order_id").where({address_id: address_id})
    if order_address.order_id != order_id
      raise "订单信息不匹配"
    end

    SalesOrderShipping.transaction do
      order_shipping                         = SalesOrderShipping.new
      order_shipping['address_id']           = address_id
      order_shipping['express_company_id']   = deliver_company
      order_shipping['express_id']           = express_id
      order_shipping['is_expected_service']  = 0
      order_shipping['expected_time']        = 0  
      order_shipping['shipping_price']       = 0  
      order_shipping['status']               = ORDER_STATUS['delivering']
      order_shipping.save

      SalesOrder.where({entity_id: order_id}).update_all( {status: order_shipping.status} )
    end

  end
end
