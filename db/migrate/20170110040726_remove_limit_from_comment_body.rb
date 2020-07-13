class RemoveLimitFromCommentBody < ActiveRecord::Migration[4.2]
  def change
    change_column :comments, :body, :string, limit: nil
  end
end
