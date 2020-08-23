class AddPronounceableNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :pronounceable_name, :string
  end
end
