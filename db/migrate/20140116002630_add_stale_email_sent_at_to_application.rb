class AddStaleEmailSentAtToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :stale_email_sent_at, :datetime
  end
end
