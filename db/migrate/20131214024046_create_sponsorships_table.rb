class CreateSponsorshipsTable < ActiveRecord::Migration
  def change
    create_table :sponsorships do |t|
      t.integer :application_id
      t.integer :user_id
      t.timestamps
    end
  end
end
