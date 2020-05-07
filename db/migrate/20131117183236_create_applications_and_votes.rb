class CreateApplicationsAndVotes < ActiveRecord::Migration[4.2]
  def change
    create_table :applications do |t|
      t.integer :user_id
      t.string :state, null: false

      t.string :summary, limit: 2000
      t.string :reasons, limit: 2000
      t.string :projects, limit: 2000
      t.string :skills, limit: 2000

      t.boolean :agreement_terms, null: false, default: false
      t.boolean :agreement_policies, null: false, default: false
      t.boolean :agreement_female, null: false, default: false

      t.timestamp :submitted_at
      t.timestamp :processed_at

      t.timestamps
    end
    add_index :applications, :user_id
    add_index :applications, :state

    create_table :votes do |t|
      t.integer :user_id, null: false
      t.integer :application_id, null: false
      t.boolean :value, null: false
      t.string :comments

      t.timestamps
    end
    add_index :votes, :user_id
    add_index :votes, :application_id
    add_index :votes, [:user_id, :application_id]

    add_column :users, :last_logged_in_at, :datetime
  end
end
