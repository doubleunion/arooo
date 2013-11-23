class Admin::UsersController < Admin::AdminController
  before_action :set_user, :only => [:edit, :update]

  def index
    @users = User.order_by_state.page(params[:page]).per(50)
    @open_applications = Application.submitted.limit(50)
  end

  def show
    @user = User.find(params.require(:id))
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:notice] = 'Profile updated'
      redirect_to :action => :edit
    else
      flash[:error] = 'Could not update profile'
      render :action => :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email,
      :profile_attributes => profile_attributes)
  end

  def profile_attributes
    [:id, :twitter, :facebook, :website, :linkedin, :blog, :bio,
     :show_name_on_site, :gravatar_email]
  end

  def set_user
    @user = current_user
  end
end
