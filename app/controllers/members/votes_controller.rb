class Members::VotesController < Members::MembersController
  def create
    application = Application.find(application_id_param)
    vote(application_id_param, !!params[:vote_yes])

    redirect_to members_application_path(application)
  end

  private

  def application_id_param
    params.require(:vote).require(:application_id)
  end
end
