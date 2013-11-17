class Admin::UsersController < Admin::AdminController
  def index
    @users = User.order_by_state.page(params[:page]).per(50)
    @open_applications = Application.submitted.page(params[:page]).per(50)
  end

  def show
    @user = User.find(params.require(:id))
  end
end
