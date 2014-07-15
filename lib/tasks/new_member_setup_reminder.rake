namespace :new_member_setup_reminder do
  desc "Send reminder emails to new members who haven't set up their accounts"
  task send_emails: :environment do
    AccountSetupReminder.new(User.setup_incomplete).send_emails
  end
end
