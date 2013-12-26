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
      flash[:error] = "Whoops, something went wrong: #{application.errors.full_messages.to_sentences}"
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
      flash[:error] = "Whoops, something went wrong: #{application.errors.full_messages.to_sentences}"
      render :applications
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

end
