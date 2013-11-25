class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :application
      t.references :user
      t.string     :comment, :limit => 2000

      t.timestamps
    end
  end
end
