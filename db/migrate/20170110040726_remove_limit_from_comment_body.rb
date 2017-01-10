class RemoveLimitFromCommentBody < ActiveRecord::Migration
  def change
    change_column :comments, :body, :string, limit: nil
  end
end
