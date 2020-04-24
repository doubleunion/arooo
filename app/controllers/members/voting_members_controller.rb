class Members::VotingMembersController < Members::MembersController
  ALL_AGREEMENTS = %w[confidentiality attended_training policy_agreement time_commitment voting_principles hard_conversations]

  def edit
  end

  def update
    if agreements_missing?
      flash[:error] = "You must agree to the statements below to become a voting member."
      return render :edit
    elsif !current_user.voting_member?
      current_user.update!(voting_policy_agreement: true)
      flash[:message] = "Thank you for volunteering to serve as a voting member! A membership coordinator will be in touch soon."
    end

    redirect_to members_root_path
  end

  private

  def agreements_missing?
    return true if params[:agreements].nil?

    agreements = params[:agreements]
    !(agreements.keys.sort == ALL_AGREEMENTS.sort && agreements.values.all? { |x| x == "1" })
  end
end
