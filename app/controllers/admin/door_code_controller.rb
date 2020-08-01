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
end
