class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV["BASIC_AUTH_NAME"], password: ENV["BASIC_AUTH_PASSWORD"] if Rails.env.staging?
  protect_from_forgery
  helper_method :current_user, :logged_in?, :logged_in_as?,
    :correct_user?, :members_page?, :vote

  before_action :set_locale

  private

  def current_user
    return @current_user if defined?(@current_user)

    if session[:user_id] && session[:user_id].to_s =~ /\d+/
      if (user = User.find_by_id(session[:user_id]))
        @current_user = user
      else
        reset_session
      end
    end
  end

  def logged_in?
    !!current_user
  end

  def logged_in_as?(user)
    logged_in? && user && current_user.id == user.id
  end

  def require_user
    unless logged_in?
      redirect_to(:root) && return
    end
  end

  def require_applicant_user
    require_user_with_state("applicant")
  end

  def require_general_member
    require_user_with_state(["member", "key_member", "voting_member"])
  end

  def require_user_with_state(states)
    unless logged_in? && states.include?(current_user.state)
      redirect_to(:root) && return
    end
  end

  def ensure_admin
    unless logged_in? && current_user.is_admin?
      redirect_to(:root) && return
    end
  end

  def set_current_user(user)
    # Reset the session after successful login, per
    # 2.8 Session Fixation – Countermeasures:
    # http://guides.rubyonrails.org/security.html#session-fixation-countermeasures
    reset_session

    session[:user_id] = user.id
  end

  def members_page?
    false
  end

  def vote(application_id_param, vote_value)
    application = Application.find(application_id_param)

    vote = current_user.vote_for(application) || Vote.new

    vote.application ||= application
    vote.user ||= current_user
    vote.value = vote_value

    vote.save!

    # current process makes the votes threshold email not helpful
    # so, for now, no email. maybe this should be deleted in the future
    # application.votes_threshold_email
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale || I18n.en
  end

  def default_url_options
    {locale: I18n.locale}
  end
end
