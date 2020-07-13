class PopulateEssayQuestionsOnProfile < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE profiles p SET summary = a.summary FROM applications a WHERE p.user_id = a.user_id"
    execute "UPDATE profiles p SET reasons = a.reasons FROM applications a WHERE p.user_id = a.user_id"
    execute "UPDATE profiles p SET projects = a.projects FROM applications a WHERE p.user_id = a.user_id"
    execute "UPDATE profiles p SET skills = a.skills FROM applications a WHERE p.user_id = a.user_id"

    change_table :applications do |t|
      t.remove :summary, :reasons, :projects, :skills
    end
  end
end
