class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :logged_in?, :correct_user?,
    :use_container?

  protected

  def set_use_container(bool)
    @_use_container = bool
  end

  private

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue Exception => e
      nil
    end
  end

  def logged_in?
    !!current_user
  end

  def correct_user?
    @user = User.find(params[:id])
    unless current_user == @user
      redirect_to root_url, :alert => "Access denied."
    end
  end

  def authenticate_user!
    unless logged_in?
      redirect_to root_url, :alert => 'You need to sign in for access to this page.'
    end
  end

  def use_container?
    return @_use_container if defined?(@_use_container)
    @_use_container = true
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

end
