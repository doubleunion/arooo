class CancelMembershipMailer < ActionMailer::Base
  default from: "Double Union <#{MEMBERSHIP_EMAIL}>"

  def cancel(user)
    @user = user

    mail(
      to: [MEMBERSHIP_EMAIL],
      cc: [user.email],
      subject: "#{user.name} is canceling their membership.",
      body: "Please remove #{user.name} from all mailing lists."
    )
  end
end
