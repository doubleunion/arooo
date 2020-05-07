class DropCancanTables < ActiveRecord::Migration[4.2]
  def up
    drop_table :users_roles
    drop_table :roles
  end

  def down
    create_table :roles do |t|
      t.string :name
      t.integer :resource_id
      t.string :resource_type
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :roles, [:name, :resource_type, :resource_id],
      name: :index_roles_on_name_and_resource_type_and_resource_id,
      using: :btree
    add_index :roles, [:name],
      name: :index_roles_on_name,
      using: :btree

    create_table :users_roles do |t|
      t.integer :user_id
      t.integer :role_id
    end
    add_index :users_roles, [:user_id, :role_id],
      name: :index_users_roles_on_user_id_and_role_id,
      using: :btree
  end
end
