#encoding: utf-8
#author cway 2013-07-09

class CategoriesController < ApplicationController
  
  # GET /index 
  def index
    @categories                         = Category.get_index_data
  end
  
  # GET /categories/new 
  def new
    @category                           = Category.new
    @categories                         = Category.all_with_name
  end
  
  # POST /categories/create 
  def create 
    category_params                     = Hash.new 
    category_params['parent_id']        = params[:category]['parent_id']
    category_params['attribute_set_id'] = 2
    category_params["entity_type_id"]   = ApplicationController::CATEGORY_TYPE_ID
    parent_id                           = category_params["parent_id"].to_i
    
    if parent_id != 0
      parent_category                   = Category.find( parent_id )
      category_params['parnet_id']      = parent_id
      category_params['level']          = parent_category.level + 1
    else
      category_params['parent_id']      = 0
      category_params['level']          = 1 
    end  
    category_params["created_at"]       = DateTime.now
    category_params["updated_at"]       = DateTime.now
      
    begin
      category                          = Category.new( category_params )
      Category.insert_category category, params
      redirect_to(@category, :notice => '类目创建成功.') 
    rescue => err
      redirect_to :action => "new", :notice => err.message
    end 
  end
  
  # /categories/1 
  def show
    begin
      @category                          = Category.find( params[:id] )
      name_list                          = Category.get_categories_name( params[:id] )
      @category.name                     = name_list[@category.entity_id]

    rescue => err
      puts err.backtrace
    end
  end
 
  def edit
    begin
      @category                          = Category.get_category_info( params[:id] )
      @categories                        = Category.all_with_name_without_children( params[:id] )
    rescue => err
      puts err.backtrace
    end
  end

  # PUT /categories/1 
  def update
    begin
      @category                          = Category.find( params[:id] )
      Category.update_category @category, params
      redirect_to :action => 'edit', :id => @category.entity_id, :notice => '类目更新成功.'
    rescue => err
      redirect_to :action => 'index', :notice => err.message
    end
  end
  
  def destroy
    begin
      @category             = Category.find(params[:id])
      @category.update_attribute("is_active", 0);
    rescue => err
      puts err.backtrace
    end
    redirect_to(categories_url)
  end
  
  # /categories/get_tree.json
  def get_tree
    product_id                           = params[:product_id]
    parent_id                            = params[:parent_id]
    @categories                          = Category.where( { parent_id: parent_id } )
    checked_categories                   = CategoryProduct.select("category_id").where(  {product_id: product_id } )
   
    include_categories                   = Array.new
    checked_categories.each do |checked_category|
      include_categories.push( checked_category.category_id );
    end

    ids_list                             = Array.new
    @categories.each do |category|
      ids_list.push( category.entity_id  )
    end
    
    category_list                        = get_caregory_list_by_ids( ids_list, include_categories )
     
    respond_to do |format|
      format.json { render :json => category_list }
    end
  end

  def get_caregory_list_by_ids( ids_list, include_categories )
    category_list                        = Array.new
    if ids_list.empty?
      return category_list
    end

    name_list                         = Category.get_categories_name( ids_list )
  
    @categories.each do |category|
      tmp_category                    = Hash.new
      tmp_category["attr"]            = { "id" => category.entity_id, "name" => name_list[category.entity_id] }

      if include_categories.include? category.entity_id
        tmp_category["attr"]["class"] = "jstree-checked"
      end

      tmp_category["data"]            = name_list[category.entity_id]
      if category.children_count != 0
         tmp_category["state"]        = "closed"
      end
      category_list.push( tmp_category ) 
    end  
    category_list
  end

end
