class AdminController < ApplicationController
  before_filter :ensure_admin
  before_filter :find_member, only: [:add_voting_member, :add_key_member, :revoke_key_member, :revoke_voting_member, :revoke_membership]

  def applications
    @to_approve = Application.to_approve
    @to_reject = Application.to_reject
    @unknown = Application.not_enough_info
  end

  def members
    @all_members = User.all_members
      .includes(:profile)
      .order_by_state

    respond_to do |format|
      format.html
      format.json { render json: @all_members.as_json(include: :profile) }
    end
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

  def add_key_member
    if @user.make_key_member
      flash[:message] = "#{@user.name} was added as a key member."
    else
      flash[:message] = "Whoops! #{@user.errors.full_messages.to_sentence}"
    end
    redirect_to admin_members_path
  end

  def revoke_key_member
    if @user.remove_key_membership
      flash[:message] = "#{@user.name} was revoked as a key member."
    else
      flash[:message] = "Whoops! #{@user.errors.full_messages.to_sentence}"
    end
    redirect_to admin_members_path
  end

  def add_voting_member
    if @user.make_voting_member
      flash[:message] = "#{@user.name} was added as a voting member."
    else
      flash[:message] = "Whoops! #{@user.errors.full_messages.to_sentence}"
    end
    redirect_to admin_members_path
  end

  def revoke_voting_member
    if @user.remove_voting_membership
      flash[:message] = "#{@user.name} was revoked as a voting member."
    else
      flash[:message] = "Whoops! #{@user.errors.full_messages.to_sentence}"
    end
    redirect_to admin_members_path
  end

  def revoke_membership
    if @user.remove_membership
      flash[:message] = "#{@user.name} was revoked as a member."
    else
      flash[:message] = "Whoops! #{@user.errors.full_messages.to_sentence}"
    end
    redirect_to admin_members_path
  end

  def new_members
    @new_members = User.new_members
  end

  def setup_complete
    user = User.find(user_params[:id])
    user.setup_complete = true
    if user.save
      ApplicationsMailer.member_access(user.application).deliver
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
        format.json { render json: { user_id: user.id } }
        format.html { redirect_to admin_new_members_path, notice: "Note saved!" }
      else
        format.json { render json: { user_id: user.id } }
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
