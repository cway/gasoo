#encoding: utf-8
#author cway 2013-07-09

class ProductsController < ApplicationController
   
  # GET /index
  def index
    @products_index_js                  =  true
    render 'index'
  end

  def list
    start                               =  params[:iDisplayStart]
    length                              =  params[:iDisplayLength]

    iTotalRecords                       =  Product.count
    iTotalDisplayRecords                =  Product.where({is_active: ACTIVE}).count
    products                            =  Product.select("entity_id").where({is_active: ACTIVE}).order("entity_id desc").offset( start ).limit( length )
    product_ids                         =  Array.new
    products.each do |product_entity|
      product_ids  << product_entity.entity_id
    end
    products                            =  internal_api( '/products', { ids: product_ids.join(",") }, "GET" )
    products_list                       =  Array.new
    products.each do |product_id, product|
      product_entity                    = [
                                           product_id,
                                           product['name'], 
                                           product['sku'], 
                                           product['price'],  
                                           "<a class=\"btn btn-info\" href=\"/products/#{product_id}/edit\"><i class=\"icon-edit icon-white\"></i>编辑</a><a class=\"btn btn-danger\" href=\"/products/#{product_id}\" data-confirm=\"确认删除?\" data-method=\"delete\" rel=\"nofollow\"><i class=\"icon-trash icon-white\"></i>删除</a>"
                                          ]
      products_list << product_entity
    end
    
    render :json => {sEcho: params[:sEcho], iTotalRecords: iTotalRecords, iTotalDisplayRecords: iTotalDisplayRecords, aaData: products_list}
  end

  # GET /products/1
  def show
    @product                            =  Product.find(params[:id])

    attribute_list                      =  Product.get_attributes( PRODUCT_TYPE_ID , @product.attribute_set_id) 
  end


  #get /get_simple_products/
  def get_simple_products 
     attribute_set_id                   =  params[:set].to_i
     type_id                            =  ApplicationController::SIMPLE_PRODUCT_ID
     conditions                         =  { :attribute_set_id => attribute_set_id, :type_id => type_id }
     products                           =  Product.where( conditions ).select("entity_id")
     ids 	                              =  Array.new
     products.each do |product|
       ids.push( product.entity_id )
     end

     products                           =  internal_api( '/products', { ids: product_ids.join(",") }, "GET" )
     ret_products                       =  Array.new 
     products.each do |product_id, product|
       tmp_product                      = 
                                          {
                                            :name    => product['name'],
                                            :sku     => product['sku'],
                                            :price   => product['price'],
                                            :qty     => product['qty']
                                          }
       ret_products                     << tmp_product
     end
     render :json               => ret_products
  end

    
  # GET /products/new
  def new
    
    if ( params.has_key? 'type' and params.has_key? 'set' )
      real_new params
    else
      @attribute_sets                  =  AttributeSet.find_all_by_entity_type_id( PRODUCT_TYPE_ID )
      @product_types                   =  ProductType.find_all_by_active( ACTIVE )
      render( "init_new" )
    end 
  end

  def real_new( params )
    configurable_product_type          = CONFIGURABLE_PRODUCT_ID  
    attribute_set_id                   = params[:set].to_i
    type_id                            = params[:type].to_i

    if type_id == CONFIGURABLE_PRODUCT_ID and (params.has_key? 'continue') == false
      configurable_attributes          = Product.get_attributes_by_frontend_input(PRODUCT_TYPE_ID, attribute_set_id, "select");
      unless configurable_attributes.empty? 
        render( "chose_configurable_attribute", :locals => {:configurable_attributes => configurable_attributes, :type => type_id, :set => attribute_set_id} )
        return
      else
        type_id                        = SIMPLE_PRODUCT_ID
      end
    end
    
    @product                           = Hash.new
    init_product_params( attribute_set_id, type_id, params )

    @group_list                        = Hash.new
    init_product_group_list( attribute_set_id )
  
    @init_new_product_js               = true 
    render( "new" )
  end

  def init_product_params( attribute_set_id, type_id, params )
    @product['attribute_set_id']                        = attribute_set_id
    @product['type_id']                                 = type_id
    @product['entity_type_id']                          = ApplicationController::PRODUCT_TYPE_ID

    if @product['type_id'] == ApplicationController::CONFIGURABLE_PRODUCT_ID
      if params[:configurable_attributes]
        @product['configurable_attributes']             = params[:configurable_attributes]
        @product['configurable_attributes'].each_with_index do | attribute_id, index |
          @product['configurable_attributes'][index]    = attribute_id.to_i
        end
        @product['required_options']                    = 1
        @product['has_options']                         = 1
      else
        @product['type_id']                             = ApplicationController::SIMPLE_PRODUCT_ID
      end
    end
  end

  def init_product_group_list( attribute_set_id )
    attribute_list                                              = Product.get_attributes( ApplicationController::PRODUCT_TYPE_ID, attribute_set_id)
    group_count                                                 = 0
    attribute_list.each do |attribute|
      unless @group_list.has_key? attribute.attribute_group_id
        @group_list[attribute.attribute_group_id]               = Hash.new 
        @group_list[attribute.attribute_group_id]["sort"]       = group_count
        @group_list[attribute.attribute_group_id]["group_name"] = attribute.attribute_group_name
        @group_list[attribute.attribute_group_id]["group_id"]   = attribute.attribute_group_id
        @group_list[attribute.attribute_group_id]["attributes"] = Array.new
        group_count += 1
      end
      
      if attribute.frontend_input == "select" or attribute.frontend_input == "multiselect"
        attribute.options                                       = AttributeOption.where( { attribute_id: attribute.attribute_id} )
      end
    
      #attribute.attribute_group_name = nil
      #@group_list[attribute.attribute_group_id]["attributes"].push( attribute )
      attribute.attribute_group_name                            = nil
      attribute.value                                           = Product.get_product_attribute_value( params[:id], attribute )
      @group_list[attribute.attribute_group_id]["attributes"].push( attribute )
    end
  end

  def fast_new
    attribute_set_id                                            = params[:set].to_i
    type_id                                                     = ApplicationController::SIMPLE_PRODUCT_ID

    @product                                                    = Product.new 
    init_product_params( attribute_set_id, type_id, params )

    @group_list                                                 = Hash.new
    init_product_group_list( attribute_set_id )
    
    
    #init_new_product_js => true load init/new_product.js
    @init_new_product_js                                        = true 
    puts @group_list.to_json
    render( "fast_new" )
  end


  # GET /products/1/edit
  def edit 
    @product                                                    = internal_api( "/product/#{params[:id]}", { id: params[:id] }, "GET" )
    @group_list                                                 = Hash.new
    product                                                     = Product.select("attribute_set_id").find( params[:id] )
    @product['attribute_set_id']                                = product.attribute_set_id
    init_product_group_list( @product['attribute_set_id'] )
    @init_new_product_js                                        = true 
  end



  # POST /products
  def create
    product_info                           =  JSON.parse( params[:body] )
    logger_info                            =  "创建商品 " + product_info['sku']
    begin 
      product                              =  internal_api( '/product', params[:body] )
      admin_logger logger_info, SUCCESS
      redirect_to :action => "edit", :id => product['id'], :notice => '商品创建成功.'
    rescue => err
      puts err.backtrace
      admin_logger logger_info, FAILED
      redirect_to :action => "new", :notice => err.message
    end
  end
  
  
  def ajax_create
    product_info                           =  JSON.parse( request.body.string )
    logger_info                            =  "创建商品 " + product_info['sku'] 
    begin  
      product                              =  internal_api( '/product', request.body.string )
      admin_logger logger_info, SUCCESS
      render :json                         => { :status => 1, :data => product }
    rescue => err
      puts err.backtrace
      admin_logger logger_info, FAILED
      render :json                         => { :status => 0, :error_msg => err.message }
    end
  end

  # PUT /products/1
  def update
    product_info                                     = JSON.parse( params[:body] )
    logger_info                                      = "更新商品 " + product_info["id"].to_s
    begin
      product                                        =  internal_api( "/product/#{product_info['id']}", params[:body], "PUT" )
      admin_logger logger_info, SUCCESS
      redirect_to :action => "edit", :id => product['id'], :notice => '更新成功'
    rescue => err
      puts err.backtrace
      admin_logger logger_info, FAILED
      redirect_to :action => "edit", :id => product_info["id"], :notice => err.message
    end
  end


  # DELETE /products/1
  def destroy
    logger_info                                     = "删除商品 " + params[:id].to_s
    begin
      product                                       =  internal_api( "/product/#{params[:id]}", { id: params[:id] }, "DELETE" )
      admin_logger logger_info, SUCCESS
    rescue => err
      admin_logger logger_info, FAILED
      puts err.backtrace
    end
    redirect_to(products_url)
  end 

  def get_children
    product_id                                      = params['entity_id']
    product                                         = internal_api( "/product/#{params['entity_id']}", { id: params['entity_id'] }, "GET" )

    #children                                        = ProductRelation.find_all_by_parent_id product_id
    unless product['configurable_children_ids']
      product['configurable_children_ids']          = Array.new
    end
    unless product['configurable_children_ids'].empty?
      product_children                              = Product.get_flashsales_attributes product['configurable_children_ids']
      render :json                                  => { :status => 1, :data => product_children }
    else
      render :json                                  => { :status => 0, :data => [] }
    end

  end

  private
  def verify_params( params ) 
    params.each  do |key, value|
      case key
        when 'price'
          unless ( Float( value ) rescue nil )
            raise ArgumentError, "价格必须为数字"
          end
      end
    end
  end

end
