class AddStaleEmailSentAtToApplication < ActiveRecord::Migration[4.2]
  def change
    add_column :applications, :stale_email_sent_at, :datetime
  end
end
