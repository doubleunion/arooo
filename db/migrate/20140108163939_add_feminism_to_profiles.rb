class AddFeminismToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :feminism, :string, limit: 2000
  end
end
