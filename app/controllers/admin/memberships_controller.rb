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

    if user.send("make_#{params[:user][:updated_state]}")
      flash[:message] = "#{user.name} is now a #{user.state.humanize.downcase}."
    else
      flash[:message] = "Whoops! #{user.errors.full_messages.to_sentence}"
    end

    redirect_to admin_memberships_path
  end
end
