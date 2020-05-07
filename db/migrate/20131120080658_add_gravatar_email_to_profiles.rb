class AddGravatarEmailToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :gravatar_email, :string
  end
end
