class Admin::ConfigurationController < ApplicationController
  before_filter :login_required
  
  def index
    @configurations = Configuration.find :all
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
  
  def authorized?
    current_user.id == 1
  end
end
