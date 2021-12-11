class Admin::DoorCodesController < ApplicationController
  before_action :ensure_admin

  def index
    @door_codes = DoorCode.all.includes(:user).order(created_at: :asc)
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

  def edit
  end

  def update
    if door_code.update(door_code_params)
      flash[:notice] = "You have successfully updated door code #{door_code.code}"
      redirect_to action: :index
    else
      flash[:warning] = "Errors saving code. See details below."
      render :edit
    end
  end

  private

  def door_code_params
    return {} unless params.key?(:door_code)

    params.require(:door_code).permit(:code, :status, :user_id, :id)
  end

  helper_method def door_code
    @door_code ||= params.key?(:id) ? DoorCode.find(params[:id]) : DoorCode.new(door_code_params)
  end
end