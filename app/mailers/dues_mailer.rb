class DuesMailer < ActionMailer::Base
  default from: "Double Union <#{I18n.t 'du.membership_email'}>"

  def failed(email)
    mail(
      to: [email, I18n.t('du.membership_email')],
      subject: "Heads Up! DU dues charge failed"
    )
  end
end
