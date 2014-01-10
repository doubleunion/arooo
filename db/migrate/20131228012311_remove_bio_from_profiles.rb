class RemoveBioFromProfiles < ActiveRecord::Migration
  def change
    remove_column :profiles, :bio, :string, :limit => 2000
  end
end
