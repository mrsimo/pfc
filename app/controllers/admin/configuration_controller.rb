class Admin::ConfigurationController < ApplicationController
  before_filter :login_required
  
  def index
    require "daemons"
    @configurations = Configuration.find :all
    @monitor = Daemons::Monitor.find "log","processor"
  end

  def update
    params[:config].each do |key,val|
      Configuration.find_by_permalink(key).update_attribute(:value, val)      
    end
    render :text => "Configuration saved"
  end

  def create
    Configuration.create(:name => params[:name])
    redirect_to :action => :index
  end
  
  def start_daemon
    require "daemons"
    @monitor = Daemons::Monitor.find "log","processor"
    if @monitor.nil?
      `lib/daemons/processor_ctl start`
    end
    flash[:notice] = "El proceso se ha iniciado."
    begin
      redirect_to :back
    rescue Exception => e
      redirect_to admin_configurations_path 
    end
  end
  
  def stop_daemon
    require "daemons"
    @monitor = Daemons::Monitor.find "log","processor"
    unless @monitor.nil?
      `lib/daemons/processor_ctl stop`
    end
    flash[:notice] = "El proceso ha recibido la orden de parar. Parará cuando acabe con el actual documento."
    begin
      redirect_to :back
    rescue Exception => e
      redirect_to admin_configurations_path 
    end
  end
  
  def authorized?
    current_user.id == 1
  end  
  
end
