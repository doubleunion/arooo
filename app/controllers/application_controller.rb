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

  def use_container?
    return @_use_container if defined?(@_use_container)
    @_use_container = true
  end
end
