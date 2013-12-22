class Members::UsersController < Members::MembersController
  before_action :set_user, :except => [:index, :show]

  def index
    @members_and_key_members = User.members_and_key_members
      .includes(:profile)
      .order_by_state
      .limit(100)

    @applicants_submitted = User.with_submitted_application.limit(50)
    @applicants_started   = User.with_started_application.limit(50)
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

  def setup
  end

  def finalize
    if @user.update_attributes(user_params)
      flash.now[:notice] = 'Account details set'
      render :action => :setup
    else
      flash.now[:error] = "Whoops, something went wrong: #{@user.errors.full_messages}"
      render :action => :setup
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email,
      :email_for_google, :dues_pledge,
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
