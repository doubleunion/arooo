class AddShowCheckboxesToProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :show_reasons, :boolean,  default: false, null: false
    add_column :profiles, :show_projects, :boolean, default: false, null: false
  end
end
