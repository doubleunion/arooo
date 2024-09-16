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

    allowed_updated_state = User.state_machine.states.map(&:name).find do |allowed|
      allowed.to_s == params.dig(:user, :updated_state)
    end
    unless allowed_updated_state
      raise ArgumentError.new("Unrecognized user state: #{params.dig(:user, :updated_state)}")
    end
    action_method = user.method("make_#{allowed_updated_state}")

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

  # updating scholarship status
  #if requested --> approve (approve=true), revoke (approve=false)
  #if approved --> revoke (approve=true), continue (approve=true)
  #if not-requested --> approve
  def approve_or_continue_scholarship
    user = User.find(params[:id])
    if user.scholarship_since?
      user.scholarship_continued
    else
      user.scholarship_approved
    end
    redirect_to admin_memberships_path
  end

  def remove_scholarship
    user = User.find(params[:id])
    user.scholarship_rejected_or_revoked
    redirect_to admin_memberships_path
  end

  private

  def user_params
    params.require(:user)
  end
end
