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
    name_attribute_id                   = Category.get_attribute_id("name")
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
    @category                           = Category.new( category_params )
       
   
    begin
     Category.transaction do
       @category.save
       if parent_category
         @category["path"]               = parent_category.path + "/" + @category.entity_id.to_s
         parent_category.children_count += 1
         parent_category.save
       else
         @category["path"]               = @category.entity_id.to_s
       end
       @category.save
      
       entity_name                       = Hash.new
       entity_name["attribute_id"]       = name_attribute_id
       entity_name["entity_id"]          = @category.entity_id
       entity_name["entity_type_id"]     = ApplicationController::CATEGORY_TYPE_ID
       entity_name["value"]              = params[:category][:name] 
       entity_value                      = CategoryEntityVarchar.new(entity_name);     
       entity_value.save
     end
      
     redirect_to(@category, :notice => '类目创建成功.')
  
    rescue => err
      @categories                        = Category.all_with_name
      render :action => "new", :notice => err 
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
    rescue
      render :json => "该商品不存在"
      return
    end

    name_attribute_id                    = Category.get_attribute_id("name")
    category_params                      = params[:category]
    category_params["entity_type_id"]    = ApplicationController::CATEGORY_TYPE_ID
    parent_id                            = category_params["parent_id"].to_i
    
    if parent_id != 0
      begin
        parent_category                  = Category.find( parent_id )
      rescue
        parent_category                  = nil
      end
      category_params['parnet_id']       = parent_id
      category_params['level']           = parent_category.level + 1
    else
      category_params['parent_id']       = 0
      category_params['level']           = 1 
    end 
   
    begin
     Category.transaction do 
       if parent_category
         category_params["path"]         = parent_category.path + "/" + @category.entity_id.to_s
       else
         category_params["path"]         = @category.entity_id.to_s
       end 

       if category_params['parnet_id']  != @category.parent_id
         if parent_category
           parent_category.children_count += 1
           parent_category.save
         end

         begin
           old_parent_category           = Category.find( @category["parent_id"] )
         rescue
           old_parent_category           = nil
         end 

         if old_parent_category
           old_parent_category.children_count -= 1
           old_parent_category.save
         end
       end

       if @category.level               != category_params['level']
         Category.update_level( @category.entity_id, category_params['level'], category_params['path'] )
       end
      
       @category.update_attributes( { :parent_id => category_params['parent_id'], :path => category_params['path'], :level => category_params['level'], :updated_at => DateTime.now } )
      
       entity_name                       = Hash.new
       entity_name["attribute_id"]       = name_attribute_id
       entity_name["entity_id"]          = @category.entity_id
       entity_name["entity_type_id"]     = ApplicationController::CATEGORY_TYPE_ID
       entity_name["value"]              = params[:category][:name]

       entity_option                     = {:entity_type_id => ApplicationController::CATEGORY_TYPE_ID, :attribute_id => name_attribute_id, :entity_id => @category.entity_id}
       entity_value                      = CategoryEntityVarchar.first( :conditions => entity_option )
       if entity_value
         entity_value.update_attribute( 'value', entity_name["value"] )
       else
         entity_value                    = CategoryEntityVarchar.new(entity_name);     
         entity_value.save
       end 
     end
      
     redirect_to(@category, :notice => '类目更新成功.')
  
    rescue => err
       puts err.backtrace
       render :action => "edit", :notice => "类目更新失败", :id => params[:id]
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
