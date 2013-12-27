class ApplicationsMailer < ActionMailer::Base
  default from: 'Double Union <membership@doubleunion.org>'

  def confirmation(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Thanks for applying to Double Union!"
    )
  end
end
