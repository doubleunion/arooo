class AddAttendanceToProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :profiles, :attendance, :string, limit: 2000
  end
end
