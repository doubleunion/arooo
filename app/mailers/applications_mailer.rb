class ApplicationsMailer < ActionMailer::Base
  MEMBERSHIP_EMAIL = 'Double Union <membership@doubleunion.org>'
  default from: MEMBERSHIP_EMAIL

  def confirmation(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Thanks for applying to Double Union!"
    )
  end

  def notify_members(application)
    member_emails = User.members_and_key_members.pluck(:email).compact
    @applicant = application.user
    mail(
      to: MEMBERSHIP_EMAIL,
      bcc: member_emails,
      subject: "New Double Union application submitted"
    )
  end
end
