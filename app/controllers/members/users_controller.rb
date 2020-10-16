class Members::UsersController < Members::MembersController
  before_action :set_user, except: [:index, :show]

  def index
    @all_members = User.all_members
      .includes(:profile)
      .order_by_state
    @all_admins = User.all_admins
      .includes(:profile)
      .order_by_state
  end

  def show
    @user = User.all_members.find(params.require(:id))
  end

  def edit
  end

  def update
    update_attrs_and_set_flash
    render action: :edit
  end

  def setup
  end

  def finalize
    update_attrs_and_set_flash
    render action: :setup
  end

  private

  def update_attrs_and_set_flash
    if @user.update_attributes(user_params)
      flash[:notice] = "Successfully updated!"
    else
      flash[:error] = "Whoops, something went wrong: #{@user.errors.full_messages}"
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :pronounceable_name,
      :email_for_google, :dues_pledge,
      profile_attributes: profile_attributes)
  end

  def profile_attributes
    [:id, :twitter, :facebook, :website, :linkedin, :blog,
     :summary, :reasons, :projects, :pronouns, :skills,
     :show_name_on_site, :gravatar_email]
  end

  def set_user
    @user = current_user
  end
end
