class AddMembershipNoteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :membership_note, :text
  end
end
