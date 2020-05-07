class CreateProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :profiles do |t|
      t.integer :user_id, null: false
      t.string :twitter
      t.string :facebook
      t.string :website
      t.string :linkedin
      t.string :blog
      t.string :bio, limit: 2000

      t.timestamps
    end

    add_index :profiles, :user_id
  end
end
