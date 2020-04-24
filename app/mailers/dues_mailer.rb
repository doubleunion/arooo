class DuesMailer < ActionMailer::Base
  default from: "Double Union <#{MEMBERSHIP_EMAIL}>"

  def failed(email)
    mail(
      to: [email, MEMBERSHIP_EMAIL],
      subject: "Heads Up! DU dues charge failed"
    )
  end

  def scholarship_requested(user, reason)
    @user = user
    @reason = reason

    mail(
      to: [SCHOLARSHIP_EMAIL, @user.email],
      subject: "New DU Scholarship Request"
    )
  end
end
