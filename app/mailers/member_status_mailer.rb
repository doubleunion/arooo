class MemberStatusMailer < ActionMailer::Base
  default from: "Double Union <#{MEMBERSHIP_EMAIL}>"

  def new_key_member(user)
    @user = user

    mail(
      to: [MEMBERSHIP_EMAIL],
      cc: [user.email],
      subject: "#{user.name} is now a key member!"
    )
  end
end
