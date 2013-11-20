class AddShowNameOnSiteToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :show_name_on_site, :boolean, :null => false, :default => false
  end
end
