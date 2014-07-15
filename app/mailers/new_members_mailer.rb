class NewMembersMailer < ActionMailer::Base

  default from: "Double Union <#{I18n.t 'du.membership_email'}>" 
  
  def three_day_reminder(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Double Union — Account Setup Needed <3"
    )
  end

  def seven_day_reminder(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Double Union — don't forget to join :D"
    )
  end

  def fourteen_day_reminder(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Double Union — join us soon?"
    )
  end

  def twenty_one_day_reminder(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Last Call for Double Union membership"
    )
  end
end
