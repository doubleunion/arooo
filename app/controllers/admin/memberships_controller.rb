class Admin::MembershipsController < ApplicationController
  before_action :ensure_admin

  def index
    @all_members = User
      .all_members
      .includes(:profile)
      .includes(:door_code)
      .order_by_state

    respond_to do |format|
      format.html
      format.json { render json: @all_members.as_json(include: :profile) }
    end
  end

  def update
    user = User.find(params[:id])

    flash[:message] = if user.update_attributes!(user_params)
      "#{user.name} updated."
    else
      "Whoops! #{user.errors.full_messages.to_sentence}"
    end

    redirect_to admin_memberships_path
  end

  def change_membership_state
    user = User.find(params[:id])

    action_method = user.method("make_#{params.dig(:user, :updated_state)}") rescue raise(NoMethodError)

    flash[:message] = if action_method.call
      "#{user.name} is now a #{user.state.humanize.downcase}."
    else
      "Whoops! #{user.errors.full_messages.to_sentence}"
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
