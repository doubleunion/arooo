class AdminController < ApplicationController
  before_action :ensure_admin

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
    @new_members = User.new_members.reorder(:last_stripe_charge_succeeded)
  end

  def setup_complete
    user = User.find(user_params[:id])
    user.setup_complete = true
    if user.save
      ApplicationsMailer.member_access(user.application).deliver_now
    else
      flash[:message] = "Whoops! #{user.errors.full_messages.to_sentence}"
    end
    redirect_to admin_new_members_path
  end

  def save_membership_note
    user = User.find(user_params[:id])
    user.membership_note = user_params[:membership_note]

    respond_to do |format|
      if user.save
        # format.json { render json: {user_id: user.id} }
        format.html { redirect_to admin_new_members_path, notice: "Note saved!" }
      else
        # format.json { render json: {user_id: user.id} }
        format.html { redirect_to admin_new_members_path, notice: "Whoops! #{user.errors.full_messages.to_sentence}" }
      end
    end
  end

  def dues
    @all_members = User.all_members
    @members_without_dues = User.no_stripe_dues
  end

  protected

  def members_page?
    false
  end

  private

  def application_params
    params.require(:application).permit(:id)
  end

  def user_params
    params.require(:user).permit(:id, :membership_note)
  end

  def find_member
    @user = User.find(params[:user][:id])
  end
end
