#encoding: utf-8
#author cway 2013-07-09

class AttributeSetsController < ApplicationController


  # GET /index
  def index
    @attribute_sets             = AttributeSet.get_index_data   
  end


  # GET /attribute_sets/new
  def new
    @entity_type                = EntityType.find( ApplicationController::PRODUCT_TYPE_ID )
    @attribute_sets             = AttributeSet.where( entity_type_id: ApplicationController::PRODUCT_TYPE_ID )
    @attribute_set              = AttributeSet.new
  end


  # POST /attribute_sets/create
  def create  
    logger_info                 = "创建属性集 " + params[:attrubute_set]['attribute_set_name']
    begin
      attrubute_set             = AttributeSet.create_attribute_set( params ) 
      @init_attribute_set_js    = true 

      admin_logger logger_info, SUCCESS
      redirect_to :action => "edit", :id => attrubute_set.attribute_set_id, :notice => '属性集创建成功.'
    rescue ActiveRecord::RecordNotUnique => err
      admin_logger logger_info, FAILED
      redirect_to :action => "new", :notice => '该属性集已存在'
    rescue => err
      admin_logger logger_info, FAILED
      redirect_to :action => "new", :notice => err.message
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
    attribute_set_id              =   params[:id]
    logger_info                   =   "更新属性集 " + attribute_set_id.to_s
    begin
      group_data                  =   params[:group_data]
      group_list                  =   JSON.parse group_data #ActiveSupport::JSON.decode( group_data )
      entity_type_id              =   params[:entity_type_id]
      EntityAttribute.where( { entity_type_id: entity_type_id, attribute_set_id: attribute_set_id } ).delete_all
      EntityAttribute.insert_attributes( group_list, entity_type_id, attribute_set_id ) 
 
      admin_logger logger_info, SUCCESS
      redirect_to  :action => 'edit', :id => attribute_set_id, :notice => "更新成功"
    rescue => err 
      admin_logger logger_info, FAILED
      redirect_to  :action => 'edit', :id => attribute_set_id, :notice => err.message
    end
  end

  # /attribute_sets/1 
  def show
    render :json => "暂不开放"
    #@attribute_set = AttributeSet.find(params[:id])
  end
end
