class Members::KeyMembersController < Members::MembersController
  def edit
  end

  def update
    @new_key_member = current_user

    if agreements_missing?
      flash[:error] = "You must agree to the statements below to become a key member."
      return render :edit
    elsif @new_key_member.member? && @new_key_member.make_key_member!
      send_keymember_email
      flash[:message] = "Yay, you're now a key member! You've just received an email with instructions for getting set up. Questions? Email #{KEYS_EMAIL}.".html_safe
    else
      flash[:error] = "Only members can become key members. If you'd like to change your membership status, email #{MEMBERSHIP_EMAIL}".html_safe
    end

    redirect_to members_root_path
  end

  private

  def agreements_missing?
    return true if params[:agreements].nil?

    agreements = params[:agreements]
    !(agreements.keys == %w[attended_events kick_out lock_up take_action] && agreements.values.all? { |x| x == "1" })
  end

  def send_keymember_email
    MemberStatusMailer.new_key_member(current_user).deliver_now
  end
end
