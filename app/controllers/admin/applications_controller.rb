class Admin::ApplicationsController < Admin::AdminController
  def show
    @application = Application.find(params.require(:id))
    @user        = @application.user
    @vote        = current_user.vote_for(@application) || Vote.new
  end
end
