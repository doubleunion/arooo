class DuesMailer < ActionMailer::Base
  default from: "Double Union <#{MEMBERSHIP_EMAIL}>"

  def failed(email)
    mail(
      to: [email, MEMBERSHIP_EMAIL],
      subject: "Heads Up! DU dues charge failed"
    )
  end
end
