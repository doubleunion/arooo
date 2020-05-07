class AddEssayQuestionsToProfile < ActiveRecord::Migration[4.2]
  def change
    change_table :profiles do |t|
      t.string "summary", limit: 2000
      t.string "reasons", limit: 2000
      t.string "projects", limit: 2000
      t.string "skills", limit: 2000
    end
  end
end
