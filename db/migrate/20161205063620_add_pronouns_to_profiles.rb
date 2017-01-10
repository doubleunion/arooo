class AddPronounsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :pronouns, :string
  end
end
