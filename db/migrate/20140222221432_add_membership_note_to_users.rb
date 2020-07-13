class AddMembershipNoteToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :membership_note, :text
  end
end
