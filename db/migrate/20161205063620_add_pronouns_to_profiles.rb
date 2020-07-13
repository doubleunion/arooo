class AddPronounsToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :pronouns, :string
  end
end
