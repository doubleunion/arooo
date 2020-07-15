class CreateDoorCodes < ActiveRecord::Migration[4.2]
  def change
    create_table :door_codes do |t|
      t.references :user, null: false, index: { unique: true }
      t.string :code, null: false, index: { unique: true }
      t.boolean :enabled, null: false, default: false
      t.timestamps
    end
  end
end
