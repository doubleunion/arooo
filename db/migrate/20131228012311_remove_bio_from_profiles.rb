class RemoveBioFromProfiles < ActiveRecord::Migration[4.2]
  def change
    remove_column :profiles, :bio, :string, limit: 2000
  end
end
