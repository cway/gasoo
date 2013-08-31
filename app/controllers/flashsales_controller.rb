#encoding: utf-8
#author cway 2013-07-10

class FlashsalesController < ApplicationController
  
  # GET /index
  def index
    @flashsales                  = EventProduct.get_daily_flashsales #find_by_rule_id( 1 );
    
    render 'index'
  end
  
  # GET /flashsales/new
  def new
    @eventrule                   = Eventrule.new
    @init_new_flashsales         = true;
    
    render 'new'
   
  end
  
  # POST /flashsales/create
  def create 
    eventrule_info                                = JSON.parse( params[:body] ) 
    logger_info                                   = "创建活动 闪购-" + Time.parse(eventrule_info['from_date']).getlocal().strftime("%Y-%m-%d")
    begin
      Eventrule.create_eventrule eventrule_info
      admin_logger logger_info, SUCCESS
      redirect_to :action => 'index', :notice => '闪购创建成功'  
    rescue => err
      admin_logger logger_info, FAILED
      redirect_to :action => 'new', :notice => err.message 
    end
  end
  
  # /flashsales/1
  # /flashsales/1.xml
  def show
    @eventproduct                                          =  EventProduct.find(params[:id])
  end
  
  def edit
    rule_id                                                =  params[:id] 
    begin  
      @eventrule                                           =  Eventrule.find( rule_id ) 
    rescue Exception => e
      puts e.backtrace
      render :json => '不存在该闪购'
      return 
    end 
 
    @eventrule.products                                    =  EventProduct.get_products_by_rule_id rule_id
    @eventrule.product_ids                                 =  Array.new
    @eventrule.products.each do |product|
      @eventrule.product_ids.push( product['product_id'] )
    end

    name_list                                              =  EventProduct.get_products_name( @eventrule.product_ids )
    @eventrule.products.each_with_index do |event_product, index|
      begin
        if name_list.has_key? event_product['product_id']
          @eventrule.products[index]['name']               =  name_list[event_product['product_id']]
          @eventrule.products[index]['price']              =  @eventrule.products[index]['normal_price']

          children                                         =  EventProductChildren.get_event_product_children event_product['event_product_id']
          if children
            children_list                                  =  Hash.new
            children_ids                                   =  Array.new
            children.each do |child|
              children_ids.push( child['product_id'] )
            end
            child_name_list                                   =  EventProduct.get_products_name( children_ids )

            children.each_with_index do |child, child_index|
              children_list[child['product_id']]              =  child
              children_list[child['product_id']]['name']      =  child_name_list[child['product_id']]
              children_list[child['product_id']]['price']     =  child['normal_price']
              children_list[child['product_id']]['entity_id'] =  child['product_id']
            end
            @eventrule.products[index]['children']            =  children_list
          end
        end
      rescue => err
        puts err.backtrace
      end
    end 
    @init_new_flashsales                                      = true;
  end

  def update 
    eventrule_info                                            = JSON.parse( params[:body] )
    products                                                  = eventrule_info['products']
    from_date                                                 = Time.parse(eventrule_info['from_date']).getlocal()
    end_date                                                  = Time.parse(eventrule_info['end_date']).getlocal()
    @eventrule                                                = Eventrule.find( eventrule_info["rule_id"] )
    logger_info                                               = "更新闪购活动 " + eventrule_info["rule_id"].to_s
    begin
      Eventrule.transaction do
        @eventrule["parent_rule_id"]                          = 1
        @eventrule["name"]                                    = "闪购-" + from_date.strftime("%Y-%m-%d")
        @eventrule["description"]                             = "杭州大厦闪购-"+ from_date.strftime("%Y-%m-%d")
        @eventrule["from_date"]                               = from_date.strftime("%Y-%m-%d %H:%M:%S")
        @eventrule["end_date"]                                = end_date.strftime("%Y-%m-%d %H:%M:%S")
        @eventrule["is_active"]                               = 1
        @eventrule.save
        EventProduct.where( :rule_id => @eventrule.rule_id ).delete_all
        products.each do |product|
          @eventproduct                                       = EventProduct.new
          @eventproduct["rule_id"]                            = @eventrule.rule_id
          @eventproduct["action_operator"]                    = 'by_price'
          @eventproduct["product_id"]                         = product["product_id"]
          @eventproduct["from_date"]                          = from_date.strftime("%Y-%m-%d %H:%M:%S")
          @eventproduct["end_date"]                           = end_date.strftime("%Y-%m-%d %H:%M:%S")
          @eventproduct["rule_price"]                         = product["rule_price"]
          @eventproduct["normal_price"]                       = product["price"]
          @eventproduct["qty"]                                = product["qty"]
          @eventproduct.save 
          if product.has_key? "children"
            EventProductChildren.where( :parent_event_product_id => @eventproduct.event_product_id ).delete_all
            product_children                                  = Array.new
            product["children"].each do |child_id, child_product|
              child_product_param                             = Hash.new
              child_product_param['parent_event_product_id']  = @eventproduct.event_product_id
              child_product_param['product_id']               = child_product['entity_id']
              child_product_param['rule_price']               = child_product['rule_price']
              child_product_param['normal_price']             = child_product['price']
              child_product_param['qty']                      = child_product['qty']
              product_children.push( child_product_param )
            end
            unless product_children.empty?
              EventProductChildren.create( product_children )
            end
          end
        end
      end
      admin_logger logger_info, SUCCESS
      redirect_to :action => 'index', :notice => '闪购修改成功'
    rescue => err
      puts err.backtrace
      admin_logger logger_info, FAILED
      redirect_to :action => 'new', :notice => err.message
    end       
  end

  # DELETE /flashsales/1
  def destroy
    render :json => "暂不开放"
    return
    @eventproduct                       = EventProduct.find(params[:id])
    @eventproduct.destroy

    redirect_to flashsales_url
  end

  def products_selector
    @products                           = Product.all
    product_types                       = ProductType.all_with_primary_key
    attribute_values                    = Product.get_index_attributes

    @init_flashsales_products_selector  = true
    render 'products_selector', :locals => { :product_types => product_types, :attribute_values => attribute_values }
  end

end
