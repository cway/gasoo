#encoding: utf-8
#author cway 2013-07-09

class AttributesController < ApplicationController
  
  # GET /index 
  def index
    @attributes                               =   EavAttribute.all
    @entity_types                             =   EntityType.all 
    entity_list                               =   Hash.new

    @entity_types.each do |entity_type|
      entity_list[entity_type.entity_type_id] =   entity_type.entity_type_code
    end
    render 'index', :locals => { :entity_list => entity_list }
  end
  
  # GET /attributrs/new
  def new
    @attribute                                =   EavAttribute.new
    @entity_types                             =   EntityType.all
    #init_attribute_set_js => true load init/attribute_set.js   
    @init_new_attribute_js                    =   true
    
    render 'new'
  end
  
  # POST /attributrs/create
  def create
    logger_info                               =   "创建属性 " + params[:attribute]['attribute_code']
    begin
      attribute                               =   EavAttribute.create_eav_attribute( params )
      admin_logger logger_info, SUCCESS
      redirect_to :action => 'edit', :id => attribute.id, :notice => '创建属性成功'
    rescue ActiveRecord::RecordNotUnique => err
      admin_logger logger_info, FAILED
      redirect_to :action => "new",  :notice => "该属性已存在"
    rescue => err
      puts err.backtrace
      admin_logger logger_info, FAILED
      redirect_to :action => "new",  :notice => err.message
    end
  end
 
  # GET /attributes/1/edit 
  def edit 
    @attribute                                =   EavAttribute.find(params[:id])
    @entity_types                             =   EntityType.all
    #init_attribute_set_js => true load init/attribute_set.js   
    @init_new_attribute_js                    =   true
  end


  def update
    logger_info                               =   "更新属性 " + params[:id].to_s
    begin
      attribute                               =   EavAttribute.update_eav_attribute( params ) 
      admin_logger logger_info, SUCCESS
      redirect_to :action => 'edit', :id => attribute.id, :notice => '修改属性成功'
    rescue => err
      puts err.backtrace
      admin_logger logger_info, FAILED
      redirect_to :action => "edit", :id => params[:id],  :notice => err.message  
    end
  end
  
  # /attributrs/1
  def show
     @attribute = EavAttribute.find( params[:id] )
  end
  
  def destory
    render :json => "暂不开放"
  end
end
