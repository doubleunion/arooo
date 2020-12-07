class Members::ApplicationsController < Members::MembersController
  def index
    @applicants_submitted = User.with_submitted_application
    @applicants_started = User.with_started_application
  end

  def show
    @application = Application.find(params.require(:id))
    @comments = visible_comments(@application)

    unless @application.submitted?
      flash[:error] = "This application is not currently visible."
      redirect_to(members_root_path) && return
    end

    @user = @application.user
    @vote = current_user.vote_for(@application) || Vote.new
    @sponsorship = current_user.sponsorship(@application)
  end

  def sponsor
    application = Application.find(application_params)

    if sponsorship_params[:is_sponsor] == "1"
      sponsorship = Sponsorship.new(user_id: current_user.id, application_id: application.id)

      if sponsorship.save
        vote(application_params, true) if current_user.voting_member?
      elsif current_user.sponsorship(application)
        flash[:notice] = "You are already sponsoring this application!"
      else
          flash[:error] = "Sorry, something went wrong!"
      end
    else
      Sponsorship.where(user_id: current_user, application_id: application).destroy_all
    end

    redirect_to members_application_path(application)
  end

  private

  def sponsorship_params
    params.permit(:is_sponsor)
  end

  def application_params
    params.require(:application_id)
  end

  # Only voting members can see all comments.
  # Non-voting general members can see only comments they themselves authored.
  # For details, see: https://github.com/doubleunion/arooo/issues/486
  # TODO: Is this the right place for this? Maybe turn this into a scope on model.
  def visible_comments(application)
    scope = if current_user.voting_member?
      application.comments
    else
      application.comments.where(user_id: current_user.id)
    end

    return scope.order(:created_at)
  end
end
