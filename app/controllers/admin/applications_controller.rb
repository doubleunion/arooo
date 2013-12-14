class Admin::ApplicationsController < Admin::AdminController
  def show
    @application = Application.find(params.require(:id))
    @comments = @application.comments

    unless @application.submitted?
      flash[:error] = 'This application is not currently visible.'
      redirect_to admin_root_path and return
    end

    @user = @application.user
    @vote = current_user.vote_for(@application) || Vote.new
    @sponsorship = current_user.sponsor(@application) || Sponsorship.new
  end

  def sponsor
    application = Application.find(application_params)

    if sponsorship_params[:user_id] == "0"
      Sponsorship.where(user_id: current_user, application_id: application).first.destroy
    else
      sponsorship = Sponsorship.new(user_id: current_user.id, application_id: application.id)

      unless sponsorship.save
        flash[:error] = "Sorry, something went wrong!"
      end
    end

    redirect_to admin_application_path(application)
  end

  private

  def sponsorship_params
    params.require(:sponsorship).permit(:user_id)
  end

  def application_params
    params.require(:application_id)
  end
end

