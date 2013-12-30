class AdminController < ApplicationController
  before_filter :ensure_admin

  def applications
    @to_approve = Application.to_approve
    @to_reject = Application.to_reject
    @unknown = Application.not_enough_info
  end

  def approve
    application = Application.find(application_params[:id])
    application.approve
    if application.save
      flash[:message] = "Successfully approved #{application.user.name}!"
      redirect_to admin_applications_path
    else
      flash[:error] = "Whoops! #{application.errors.full_messages.to_sentence}"
      render :applications
    end
  end

  def reject
    application = Application.find(application_params[:id])
    application.reject
    if application.save
      flash[:message] = "Successfully rejected #{application.user.name}."
      redirect_to admin_applications_path
    else
      flash[:error] = "Whoops! #{application.errors.full_messages.to_sentence}"
      render :applications
    end
  end

  def new_members
    @new_members = User.new_members
  end

  def setup_complete
    user = User.find(user_params)
    user.setup_complete = true
    if user.save
      redirect_to admin_new_members_path
    else
      flash[:message] = "Whoops! #{user.errors.full_messages.to_sentence}"
      redirect_to admin_new_members_path
    end
  end

  protected

  def members_page?
    true
  end

  private

  def ensure_admin
    unless logged_in? && current_user.is_admin?
      redirect_to :root and return
    end
  end

  def application_params
    params.require(:application).permit(:id)
  end

  def user_params
    params.require(:id)
  end

end
