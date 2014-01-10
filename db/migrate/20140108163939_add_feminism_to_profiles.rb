class AddFeminismToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :feminism, :string, limit: 2000
  end
end
