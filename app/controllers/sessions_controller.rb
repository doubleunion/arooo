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

    if user.visitor?
      user.make_applicant!
      redirect_to edit_application_path(user.application) and return
    elsif user.applicant?
      redirect_to edit_application_path(user.application) and return
    elsif user.former_member?
      flash[:message] = "As a former member, you can no longer access the members sections."
      redirect_to root_path and return
    elsif user.member_or_key_member?
      redirect_to members_root_path and return
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
