class Members::ApplicationsController < Members::MembersController
  def index
    @applicants_submitted = User.with_submitted_application.includes(:application).includes(:sponsorships)
    @applicants_started = User.with_started_application
    @emails_with_no_sponsors = []
    @emails_with_sponsors = []
    @applicants_submitted.each do |applicant|
      if applicant.application.sponsorships.size > 0
        @emails_with_sponsors << applicant.email
      else
        @emails_with_no_sponsors << applicant.email
      end
    end
  end

  def show
    @application = Application.find(params.require(:id))
    @comments = @application.comments.visible_to(current_user).order(:created_at)

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
end
