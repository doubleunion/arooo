class CreateComments < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.integer :user_id, null: false
      t.integer :application_id, null: false
      t.string :body, null: false, limit: 2000

      t.timestamps
    end

    add_index :comments, :user_id
  end
end
