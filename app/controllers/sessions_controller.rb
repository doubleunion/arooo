class SessionsController < ApplicationController

  def login
    redirect_to members_root_path if current_user.try(:general_member?)
  end

  def github
    redirect_to "/auth/github"
  end

  def google
    redirect_to "/auth/google_oauth2"
  end

  def create
    omniauth = request.env["omniauth.auth"]
    conditions = {provider: omniauth["provider"],
                  uid: omniauth["uid"].to_s}

    authentication = Authentication.where(conditions).first

    if current_user.present? && already_has_auth?(omniauth)
      redirect_to members_root_path
    elsif current_user.present?
      add_auth_and_redirect(omniauth)
    elsif authentication.try(:user)
      set_session_and_redirect_returning_users(authentication.user)
    else
      set_auth_session_vars(omniauth)
      redirect_to get_email_path
    end
  end

  def destroy
    reset_session
    redirect_to root_url, notice: "You have logged out"
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
  end

  def get_email
  end

  def confirm_email
    if new_user?
      user = User.create(username: session[:username], email: params[:email])

      if user.save
        make_auth(user)
        user.make_applicant!
        set_user_session(user)
        redirect_to edit_application_path(user.application)
      else
        flash[:message] = user.errors.full_messages.to_sentence
        render :get_email
      end
    else
      redirect_to root_path, alert: "It looks like you've previously logged in with a different authentication provider, so try logging in with a different one. Email admin@doubleunion.org for help if that isn't the case!"
    end
  end

  private

  def set_session_and_redirect_returning_users(user)
    set_user_session(user)

    if user.applicant?
      redirect_to(edit_application_path(user.application)) && return
    elsif user.former_member?
      flash[:message] = "As a former member, you can no longer access the members sections."
      redirect_to(root_path) && return
    elsif user.general_member?
      redirect_to(members_root_path) && return
    else
      user.make_applicant!
      redirect_to(edit_application_path(user.application)) && return
    end
  end

  def make_auth(user)
    authentication = user.authentications.build
    authentication.provider = session[:provider]
    authentication.uid = session[:uid]
    authentication.save!
  end

  def set_auth_session_vars(omniauth)
    omniauth = set_provider(omniauth)

    session[:provider] = omniauth.provider
    session[:uid] = omniauth.uid
    session[:username] = omniauth.try(:username) || omniauth.try(:email)
  end

  def add_auth_and_redirect(omniauth)
    user = current_user
    omniauth = set_provider(omniauth)

    authentication = user.authentications.build
    authentication.provider = omniauth.provider
    authentication.uid = omniauth.uid

    flash[:alert] = if authentication.save!
      "#{omniauth.provider} authentication added!"
    else
      "Whoops, something went wrong! Sorry. Email admin@doubleunion.org if this keeps happening."
    end

    redirect_to edit_members_user_path(user.id)
  end

  def set_user_session(user)
    set_current_user(user)
    user.logged_in!
  end

  def set_provider(omniauth)
    if omniauth["provider"] == "github"
      GithubAuth.new(omniauth)
    elsif omniauth["provider"] == "google_oauth2"
      GoogleAuth.new(omniauth)
    end
  end

  def new_user?
    User.where(email: params[:email]).empty?
  end

  def already_has_auth?(omniauth)
    current_auths = current_user.authentications.pluck(:provider)
    current_auths.include?(omniauth["provider"])
  end
end
