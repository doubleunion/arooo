class UsersController < ApplicationController
  before_action :require_member_or_key_member_user
  before_action :set_user, :only => [:edit, :update]

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:notice] = 'Settings updated'
      redirect_to :action => :edit
    else
      flash[:error] = 'Could not update settings'
      render :action => :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email,
      :profile_attributes => profile_attributes)
  end

  def profile_attributes
    [:id, :twitter, :facebook, :website, :linkedin, :blog, :bio]
  end

  def set_user
    @user = current_user
  end
end
