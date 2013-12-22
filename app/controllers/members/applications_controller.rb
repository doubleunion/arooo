class Members::ApplicationsController < Members::MembersController
  def show
    @application = Application.find(params.require(:id))
    @comments = @application.comments

    unless @application.submitted?
      flash[:error] = 'This application is not currently visible.'
      redirect_to members_root_path and return
    end

    @user = @application.user
    @vote = current_user.vote_for(@application) || Vote.new
    @sponsorship = current_user.sponsor(@application)
  end

  def sponsor
    application = Application.find(application_params)

    if sponsorship_params[:is_sponsor] == "1"
      sponsorship = Sponsorship.new(user_id: current_user.id, application_id: application.id)

      unless sponsorship.save
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

