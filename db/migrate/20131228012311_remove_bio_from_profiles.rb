class RemoveBioFromProfiles < ActiveRecord::Migration
  def change
    remove_column :profiles, :bio
  end
end
