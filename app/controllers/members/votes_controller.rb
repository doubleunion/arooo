class Members::VotesController < Members::MembersController
  def create
    vote(application_id_param, !!params[:vote_yes])

    application = Application.find(application_id_param)
    redirect_to members_application_path(application)
  end

  def destroy
    vote = Vote.where(application_id: params[:id], user_id: current_user.id).first

    if vote.destroy
      flash[:notice] = "Your vote has been removed"
    else
      flash[:error] = "Whoops, something went wrong!"
    end

    redirect_to members_application_path(Application.find(params[:id]))
  end

  private

  def application_id_param
    params.require(:vote).require(:application_id)
  end
end
