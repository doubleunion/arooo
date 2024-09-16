class AddScholarshipSinceToUser < ActiveRecord::Migration[6.0]
  def change
    # Currently have a boolean column is_scholarship
    # Add a column requested_scholarship
    #     that can be used to show who's requested a scholarship (approved or waiting)
    # Add a column scholarship_since
    #     to show date the scholarship was approved
    # Add a column scholarship_last_checkin
    #     to show the last check-in and member requested to continue scholarship
    # For default date values, if is_scholarship is true,
    #     will set dates to 2022-07-10 (as approximate time of last checkin)
    # To revert this migration, will have to go back to single boolean column
    
    reversible do |dir|
      dir.up do
        add_column :users, :requested_scholarship, :timestamp, default: nil
        add_column :users, :scholarship_since, :timestamp, default: nil
        add_column :users, :scholarship_last_checkin, :timestamp, default: nil

        execute "UPDATE users SET requested_scholarship = '2022-07-10', scholarship_since = '2022-07-10', scholarship_last_checkin = '2022-07-10' WHERE is_scholarship = true"
        
        remove_column :users, :is_scholarship
      end
    
      dir.down do
        add_column :users, :is_scholarship, :boolean, default: false

        execute "UPDATE users SET is_scholarship = true WHERE scholarship_since IS NOT NULL"
        
        remove_columns :users, :requested_scholarship, :scholarship_since, :scholarship_last_checkin
      end
    end
  end
end
