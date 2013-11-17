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
    user.logged_in!

    if omniauth_return_to == new_application_path
      if user.visitor?
        user.make_applicant!
      elsif user.member_or_key_member?
        flash[:error] = 'You must be an applicant to view this page.'
      end
      redirect_to omniauth_return_to
    else
      # Non-application signup/login
      flash[:notice] = "Welcome, #{user.username}!"
      redirect_to :root
    end
  end

  def omniauth_return_to
    if request.env['omniauth.params']
      request.env['omniauth.params']['return_to']
    end
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'You have logged out'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end
end
