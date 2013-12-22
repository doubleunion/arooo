class Members::VotesController < Members::MembersController
  def create
    application = Application.find(application_id_param)

    vote = current_user.vote_for(application) || Vote.new

    vote.application ||= application
    vote.user        ||= current_user
    vote.value         = !!params[:vote_yes]

    vote.save!

    redirect_to members_application_path(application)
  end

  private

  def application_id_param
    params.require(:vote).require(:application_id)
  end
end
