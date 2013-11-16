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
    return @current_user if defined?(@current_user)

    if session[:user_id] && session[:user_id].to_s =~ /\d+/
      if user = User.find_by_id(session[:user_id])
        @current_user = user
      else
        reset_session
      end
    end
  end

  def logged_in?
    !!current_user
  end

  def require_user
    unless logged_in?
      redirect_to :root and return
    end
  end

  def set_current_user(user)
    # Reset the session after successful login, per
    # 2.8 Session Fixation – Countermeasures:
    # http://guides.rubyonrails.org/security.html#session-fixation-countermeasures
    reset_session

    session[:user_id] = user.id
  end

  def use_container?
    return @_use_container if defined?(@_use_container)
    @_use_container = true
  end
end
