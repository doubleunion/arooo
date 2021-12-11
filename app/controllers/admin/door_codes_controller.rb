class Admin::DoorCodesController < ApplicationController
  before_action :ensure_admin

  def index
    @door_codes = DoorCode.all.includes(:user)
  end

  def new ; end

  def create
    if door_code.save
      flash[:notice] = "You have successfully created door code #{door_code.code}"
      redirect_to action: :index
    else
      flash[:warning] = "Errors saving code. See details below."
      render :new
    end
  end

  private

  def door_code_params
    return {} unless params.key?(:door_code)

    params.require(:door_code).permit(:code, :status, :user_id)
  end

  helper_method def door_code
    @door_code ||= DoorCode.new(door_code_params)
  end
end
