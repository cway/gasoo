#encoding: utf-8
#author cway 2013-07-09

class AttributeSetsController < ApplicationController
  
  # GET /index
  def index
    @attribute_sets             = AttributeSet.get_index_data
    puts @attribute_sets.to_json
  end
  
  # GET /attribute_sets/new
  def new
    @entity_type                = EntityType.find( ApplicationController::PRODUCT_TYPE_ID )
    @attribute_sets             = AttributeSet.find_all_by_entity_type_id( ApplicationController::PRODUCT_TYPE_ID )
    @attribute_set              = AttributeSet.new
  end
  
  # POST /attribute_sets/create
  def create 
    @attribute_set              = AttributeSet.new(params[:attribute_set])

    
    if @attribute_set.save
      parent_group_attributes   = EntityAttribute.find_all_by_attribute_set_id( params[:attribute_set][:parent_set_id] )    
      res                       = EntityAttribute.clone_parent_attributes( @attribute_set, parent_group_attributes )
      @init_attribute_set_js    = true        
      render :action => "edit", :notice => '属性集创建成功.'
    else
      @entity_types             = EntityType.all
      render :action => "new"
    end
  end
  
  # GET /attribute_sets/1/edit
  def edit
    @attribute_set              =   AttributeSet.find(params[:id])
    #init_attribute_set_js => true load init/attribute_set.js
    @init_attribute_set_js      =   true
  end
 
  # PUT /attribute_set/1
  def update 
    attribute_set_id            =   params[:id]
    group_data                  =   params[:group_data]
    group_list                  =   ActiveSupport::JSON.decode( group_data )
    entity_type_id              =   params[:entity_type_id]
    res                         =   EntityAttribute.delete_all(["entity_type_id = ? and attribute_set_id = ?", entity_type_id, attribute_set_id]) 
    
    res                         =   EntityAttribute.insert_attributes( group_list, entity_type_id, attribute_set_id ) 

    redirect_to  :action => 'index'
  end
  
  # /attribute_sets/1 
  def show
    render :json => "暂不开放"
    #@attribute_set = AttributeSet.find(params[:id])
  end
end
