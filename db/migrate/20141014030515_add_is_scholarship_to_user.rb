class AddIsScholarshipToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_scholarship, :boolean, default: false
  end
end
