namespace :scheduler do
  desc "Send email to 2+ week old application users"
  task no_sponsor_email: :environment do
    Application.all.each do |application|
      application.no_sponsor_email
    end
  end

  desc "Send reminder emails to new members who haven't set up their accounts"
  task setup_reminder_emails: :environment do
    AccountSetupReminder.new(User.new_members).send_emails
  end
end
