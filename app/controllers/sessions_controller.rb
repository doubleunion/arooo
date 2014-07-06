class SessionsController < ApplicationController
  def github
    redirect_to '/auth/github'
  end

  def google
    redirect_to '/auth/google_oauth2'
  end

  def create
    omniauth = request.env['omniauth.auth']
    conditions = { :provider => omniauth['provider'],
                   :uid      => omniauth['uid'].to_s }

    authentication = Authentication.where(conditions).first

    if authentication.try(:user)
      set_session_and_redirect_returning_users(authentication.user)
    else
      set_auth_session_vars(omniauth)
      redirect_to get_email_path
    end
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'You have logged out'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

  def get_email
  end

  def confirm_email
    if User.where(email: params[:email]).empty?
      user = create_user_and_auth
      user.make_applicant!
      set_user_session(user)

      redirect_to edit_application_path(user.application)
    else
      redirect_to root_path, alert: "It looks like you've previously logged in with a different authentication provider, so try logging in with a different one. Email admin@doubleunion.org for help if that isn't the case!"
    end
  end

  private

    def set_session_and_redirect_returning_users(user)
      set_user_session(user)

      if user.applicant?
        redirect_to edit_application_path(user.application) and return
      elsif user.former_member?
        flash[:message] = "As a former member, you can no longer access the members sections."
        redirect_to root_path and return
      elsif user.member_or_key_member?
        redirect_to members_root_path and return
      else
        user.make_applicant!
        redirect_to edit_application_path(user.application) and return
      end
    end

    def create_user_and_auth
      user = User.create!(
        username: session[:username],
        email: params[:email]
      )

      authentication          = user.authentications.build
      authentication.provider = session[:provider]
      authentication.uid      = session[:uid]
      authentication.save!

      user
    end

    def set_auth_session_vars(omniauth)
      if omniauth['provider'] == "github"
        omniauth = GithubAuth.new(omniauth)
      elsif omniauth['provider'] == "google_oauth2"
        omniauth = GoogleAuth.new(omniauth)
      end

      session[:provider] = omniauth.provider
      session[:uid] = omniauth.uid
      session[:username] = omniauth.try(:username) || omniauth.try(:email)
    end

    def set_user_session(user)
      set_current_user(user)
      user.logged_in!
    end
end
