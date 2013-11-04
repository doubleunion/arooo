class UsersController < ApplicationController
  before_filter :require_non_visitor_user
  before_filter :set_user, :only => [:edit, :update]

  def edit
  end

  def update
    attrs = params.require(:user).permit(:name, :email)
    if @user.update_attributes(attrs)
      flash[:notice] = 'Settings updated'
      redirect_to :action => :edit
    else
      flash[:error] = 'Could not update settings'
      render :action => :edit
    end
  end

  private

  def set_user
    @user = current_user
  end
end
