class Admin::MembershipsController < ApplicationController
  before_filter :ensure_admin

  def index
    @all_members = User.all_members.includes(:profile).order_by_state

    respond_to do |format|
      format.html
      format.json { render json: @all_members.as_json(include: :profile) }
    end
  end

  def update
    user = User.find(params[:id])

    if user.update_attributes!(user_params)
      flash[:message] = "#{user.name} updated."
    else
      flash[:message] = "Whoops! #{user.errors.full_messages.to_sentence}"
    end

    redirect_to admin_memberships_path
  end

  def change_membership_state
    user = User.find(params[:id])

    if user.send("make_#{params[:user][:updated_state]}")
      flash[:message] = "#{user.name} is now a #{user.state.humanize.downcase}."
    else
      flash[:message] = "Whoops! #{user.errors.full_messages.to_sentence}"
    end

    redirect_to admin_memberships_path
  end

  def make_admin
    user = User.find(params[:id])
    user.make_admin!
    flash[:message] = "#{user.name} is now an admin"
    redirect_to admin_memberships_path
  end

  def unmake_admin
    user = User.find(params[:id])
    user.unmake_admin!
    flash[:message] = "#{user.name} is now NOT an admin"
    redirect_to admin_memberships_path
  end

  private

  def user_params
    params.require(:user).permit(:is_scholarship)
  end
end
