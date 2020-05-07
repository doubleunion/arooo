class AddShowNameOnSiteToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :show_name_on_site, :boolean, null: false, default: false
  end
end
