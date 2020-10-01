class AccountSetupReminder
  def initialize(users)
    @users = users
  end

  def send_emails
    @users.each do |user|
      processed_at = user.application.processed_at
      next unless processed_at

      if processed_at < 2.days.ago && processed_at > 4.days.ago
        NewMembersMailer.three_day_reminder(user).deliver_now
      elsif processed_at < 6.days.ago && processed_at > 8.days.ago
        NewMembersMailer.seven_day_reminder(user).deliver_now
      elsif processed_at < 13.days.ago && processed_at > 15.days.ago
        NewMembersMailer.fourteen_day_reminder(user).deliver_now
      elsif processed_at < 20.days.ago && processed_at > 22.days.ago
        NewMembersMailer.twenty_one_day_reminder(user).deliver_now
      end
    end
  end
end
