class Admin::DoorCodeController < ApplicationController
  before_action :ensure_admin

  def disable_door_code
    door_code = DoorCode.find(params[:id])
    door_code.enabled = false
    door_code.save!
    flash[:message] = "#{door_code.user.name}'s door code is now disabled."
    redirect_to admin_memberships_path
  end

  def enable_door_code
    door_code = DoorCode.find(params[:id])
    door_code.enabled = true
    door_code.save!
    flash[:message] = "#{door_code.user.name}'s door code is now enabled."
    redirect_to admin_memberships_path
  end

  def generate_new_for_user
    user = User.find(params[:id])
    DoorCode.new_for_user(user)
    flash[:message] = "A door code was generated for #{user.name}."
    redirect_to admin_memberships_path
  end
end
