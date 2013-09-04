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

    products                            =  Product.select("entity_id").offset( start ).limit( length )
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
    
    render :json => {sEcho: params[:sEcho], iTotalRecords: Product.count, iTotalDisplayRecords: Product.count, aaData: products_list}
  end

  # GET /products/1
  def show
    @product                            =  Product.find(params[:id])

    attribute_list                      =  Product.get_attributes( ApplicationController::PRODUCT_TYPE_ID , @product.attribute_set_id) 
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

     attribute_values                   =  Product.get_simple_products_attributes( ids )
     products.each_with_index do |product, index|
       products[index]["name"]          =  attribute_values[:name][product.entity_id]
       products[index]["sku"]           =  attribute_values[:sku][product.entity_id]
       products[index]["price"]         =  attribute_values[:price][product.entity_id]
       products[index]["qty"]           =  attribute_values[:qty][product.entity_id]
     end
     render :json               => products
  end

    
  # GET /products/new
  def new
    
    if ( params.has_key? 'type' and params.has_key? 'set' )
      real_new params
    else
      @attribute_sets                  =  AttributeSet.find_all_by_entity_type_id( ApplicationController::PRODUCT_TYPE_ID )
      @product_types                   =  ProductType.find_all_by_active( ApplicationController::ACTIVE )
      render( "init_new" )
    end 
  end

  def real_new( params )
    configurable_product_type          = ApplicationController::CONFIGURABLE_PRODUCT_ID  
    attribute_set_id                   = params[:set].to_i
    type_id                            = params[:type].to_i

    if type_id == ApplicationController::CONFIGURABLE_PRODUCT_ID and (params.has_key? 'continue') == false
      configurable_attributes          = Product.get_attributes_by_frontend_input(ApplicationController::PRODUCT_TYPE_ID, attribute_set_id, "select");
      unless configurable_attributes.empty? 
        render( "chose_configurable_attribute", :locals => {:configurable_attributes => configurable_attributes, :type => type_id, :set => attribute_set_id} )
        return
      else
        type_id                        = ApplicationController::SIMPLE_PRODUCT_ID
      end
    end
    
    @product                           = Product.new
    init_product_params( attribute_set_id, type_id, params )

    @group_list                        = Hash.new
    init_product_group_list( attribute_set_id )
 
    #init_new_product_js => true load init/new_product.js
    @init_new_product_js               = true 
    render( "new" )
  end

  def init_product_params( attribute_set_id, type_id, params )
    @product.attribute_set_id          = attribute_set_id
    @product.type_id                   = type_id
    @product.entity_type_id            = ApplicationController::PRODUCT_TYPE_ID

    if @product.type_id == ApplicationController::CONFIGURABLE_PRODUCT_ID
      if params[:configurable_attributes]
        @product.configurable_attributes             = params[:configurable_attributes]
        @product.configurable_attributes.each_with_index do | attribute_id, index |
          @product.configurable_attributes[index]    = attribute_id.to_i
        end
        @product.required_options     = 1
        @product.has_options          = 1
      else
        @product.type_id              = ApplicationController::SIMPLE_PRODUCT_ID
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
    init_product_group_list( product.attribute_set_id )

    # if @product.type_id.to_i == ApplicationController::CONFIGURABLE_PRODUCT_ID
    #   children                                                  = ProductRelation.find(:all, :conditions => [ "parent_id = #{@product.entity_id}" ], :select => "child_id" )
    #   @product.children                                         = Array.new 
    #   children.each do |child|
    #     @product.children.push( child.child_id )
    #   end
    #   configurable_attributes                                   = ProductConfigurableAttribute.find(:all, :conditions => ["product_id = #{@product.entity_id}"], :select => "attribute_id"  )
    #   @product.configurable_attributes                          = Array.new
    #   configurable_attributes.each do |configurable_attribute|
    #     @product.configurable_attributes.push( configurable_attribute.attribute_id )
    #   end 
    # end 

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
    

    # begin 
    #   product                              =  Product.create_product product_info
    #   admin_logger logger_info, SUCCESS
    #   redirect_to :action => "edit", :id => product.entity_id, :notice => '商品创建成功.'
    # rescue => err
    #   puts err.backtrace
    #   admin_logger logger_info, FAILED
    #   redirect_to :action => "new", :notice => err.message
    # end 
  end
  
  
  def ajax_create
    product_info                           =  JSON.parse( request.body.string )
    logger_info                            =  "创建商品 " + product_info['sku'] 
    begin  
      product                              =  internal_api( '/product', params[:body] )
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
    product_info                                   = JSON.parse( params[:body] )
    logger_info                                    = "更新商品 " + product_info["entity_id"].to_s
    @product                                       = Product.find(product_info["entity_id"])
    attribute_list                                 = Product.get_attributes(ApplicationController::PRODUCT_TYPE_ID, product_info["attribute_set_id"])


    attribute_values                               = Hash.new 
   
    attribute_list.each do |attribute|
      if product_info.has_key? attribute.attribute_code and product_info[attribute.attribute_code] != ""
        attribute_values[attribute.attribute_code] =  product_info[attribute.attribute_code]
      end 
    end 

    begin 
      Product.transaction do
        Product.update_product_attributes( @product, attribute_values )
        CategoryProduct.where( :product_id => @product.entity_id ).delete_all
        categories                                 = product_info["categories"]

        unless categories.empty?
          Product.add_categories( @product.entity_id, categories )
        end

        ProductRelation.where( :parent_id => @product.entity_id ).delete_all
        if product_info.has_key? "simple_products_ids"
          product_relations                        = Array.new
          product_info["simple_products_ids"].each do |simple_product_id|
            product_relation_params                = Hash.new
            product_relation_params["parent_id"]   = @product.entity_id
            product_relation_params["child_id"]    = simple_product_id
            product_relations.push( product_relation_params )
          end
          ProductRelation.create( product_relations )
        end

        @product.sku                               = product_info['sku']
        @product.updated_at                        = Time.now
        @product.save
      end
      admin_logger logger_info, SUCCESS
      redirect_to :action => "edit", :id => @product.entity_id, :notice => '更新成功'
    rescue => err
      puts err.backtrace
      admin_logger logger_info, FAILED
      redirect_to :action => "edit", :id => product_info["entity_id"], :notice => err.message
    end
  end


  # DELETE /products/1
  def destroy
    logger_info                                     = "删除商品 " + params[:id].to_s
    begin
      @product                                      = Product.find(params[:id])
      @product.update_attribute("is_active", 0);
      admin_logger logger_info, SUCCESS
    rescue => err
      admin_logger logger_info, FAILED
      puts err.backtrace
    end
    redirect_to(products_url)
  end 

  def get_children
    product_id                                      = params['entity_id']
    children                                        = ProductRelation.find_all_by_parent_id product_id
    unless children.empty?
      children_ids                                  = Array.new
      children.each do |child|
        children_ids.push( child.child_id )
      end 
      product_children                              = Product.get_flashsales_attributes children_ids
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
