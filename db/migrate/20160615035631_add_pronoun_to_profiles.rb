class AddPronounToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :pronoun, :string
  end
end
