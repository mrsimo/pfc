class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_to :controller => '/website', :action => 'panel'
      flash[:notice] = "Logged in successfully"
    else 
      redirect_to :controller => '/website', :action => 'index'
      flash[:notice] = "Incorrect user or password. Try again"
    end
  end
  
  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user    
    redirect_to :controller => '/website', :action => 'panel'
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    flash[:type] = "bad"
    redirect_back_or_default(:controller => '/website', :action => 'index')
  end
end
