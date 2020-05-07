class AddIsScholarshipToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :is_scholarship, :boolean, default: false
  end
end
