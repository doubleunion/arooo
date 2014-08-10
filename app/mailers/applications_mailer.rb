class ApplicationsMailer < ActionMailer::Base
  default from: "Double Union <#{JOIN_EMAIL}>"

  def confirmation(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Thanks for applying to Double Union!"
    )
  end

  def notify_members(application)
    member_emails = User.all_members.pluck(:email).compact
    @applicant = application.user
    mail(
      to: JOIN_EMAIL,
      bcc: member_emails,
      subject: "New Double Union application submitted"
    )
  end

  def approved(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Welcome to Double Union!!!"
    )
  end

  def no_sponsor(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Your Double Union application is awaiting a sponsor"
    )
  end

  def votes_threshold(application)
    @user = application.user
    @application = application
    mail(
      to: JOIN_EMAIL,
      subject: "A Double Union application hit the votes threshold!"
    )
  end

  def member_access(application)
    @user = application.user
    @application = application
    mail(
      to: @user.email,
      subject: "You now have Double Union access!"
    )
  end
end
