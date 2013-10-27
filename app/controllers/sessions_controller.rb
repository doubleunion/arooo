class SessionsController < ApplicationController
  def new
    redirect_to '/auth/github'
  end

  def create
    auth = request.env['omniauth.auth']
    conditions = { :provider => auth['provider'],
                   :uid      => auth['uid'].to_s)

    user = User.where(conditions).first || User.create_with_omniauth(auth)

    # Reset the session after successful login, per
    # 2.8 Session Fixation – Countermeasures:
    # http://guides.rubyonrails.org/security.html#session-fixation-countermeasures
    reset_session
    session[:user_id] = user.id
    redirect_to root_url, :notice => 'You are now logged in'
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Logged out'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

end
