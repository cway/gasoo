#encoding: utf-8
#author cway 2013-07-10

class EventrulesController < ApplicationController
  
  # GET /index
  def index
    @eventrules       = Eventrule.all
  end
  
  # GET /eventrules/new
  def new          
    @eventrules       = Eventrule.new
  end
  
  # POST /eventrules/create 
  def create 
    eventrule        = Eventrule.new(params[:eventrule])

    if eventrule.save
      redirect_to(eventrule,  :notice => '活动创建成功.')  
    else
      render :action => "new" 
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
    begin
      eventrule        = Eventrule.find( params[:id] )

      if eventrule.update_attributes( params[:eventrule] )
        redirect_to(eventrule,  :notice => '活动更新成功.')  
      else
        render :action => "edit", :id => params[:id]
      end
    rescue => err
      puts err.backtrace
    end 
  end

  def destory
    begin
      eventrule      = Eventrule.find(params[:id])
      eventrule.update_attribute("is_active", 0);
    rescue => err
      puts err.backtrace
    end
    redirect_to(eventrules_url)
  end
end
