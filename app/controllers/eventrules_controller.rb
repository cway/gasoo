#encoding: utf-8
#author cway 2013-07-10

class EventrulesController < ApplicationController
  
  # GET /index
  def index
    @eventrules          = Eventrule.all
  end
  
  # GET /eventrules/new
  def new          
    @eventrules          = Eventrule.new
  end
  
  # POST /eventrules/create 
  def create 
    logger_info          = "创建活动 " + params[:eventrule]['name']
    eventrule            = Eventrule.new( params[:eventrule].permit! )

    if eventrule.save
      admin_logger logger_info, SUCCESS
      redirect_to :action => 'edit', :id => eventrule.rule_id,  :notice => '活动创建成功.'
    else
      admin_logger logger_info, FAILED
      render :action => "new", :notice => "活动创建失败"
    end
  end
  
  # /eventrules/1
  def show
    begin
      @eventrule        =  Eventrule.find( params[:id] )
    rescue => err
      puts err.backtrace
    end
  end
  
  def edit
    begin
      @eventrule        =  Eventrule.find( params[:id] )
    rescue => err
      puts err.backtrace
    end
  end

  def update
    logger_info         = "更新活动 " + params[:id].to_s
    begin
      eventrule         = Eventrule.find( params[:id] )

      if eventrule.update_attributes( params[:eventrule].permit! )
        admin_logger logger_info, SUCCESS
        redirect_to :action => 'edit', :id => params[:id], :notice => '活动更新成功.'
      else
        admin_logger logger_info, FAILED
        render :action => "edit", :id => params[:id], :notice => "更新活动失败"
      end
    rescue => err
      puts err.backtrace
    end 
  end

  def destory
    logger_info         = "删除活动 " + params[:id]
    begin
      eventrule        = Eventrule.find(params[:id])
      eventrule.update_attribute("is_active", 0);
      admin_logger logger_info, SUCCESS
    rescue => err
      admin_logger logger_info, FAILED
      puts err.backtrace
    end
    redirect_to(eventrules_url)
  end
end
