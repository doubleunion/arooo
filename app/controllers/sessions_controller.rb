class SessionsController < ApplicationController
  def new
    redirect_to '/auth/github'
  end

  def create
    auth = request.env['omniauth.auth']
    conditions = { :provider => auth['provider'],
                   :uid      => auth['uid'].to_s }

    user   = User.where(conditions).first
    user ||= User.find_and_update_provisioned(auth)
    user ||= User.create_with_omniauth(auth)

    set_current_user(user)

    flash[:notice] = "Welcome, #{user.username}!"
    redirect_to :root
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'You have logged out'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end
end
