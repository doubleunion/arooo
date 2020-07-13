class AddVotingPolicyAgreementToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :voting_policy_agreement, :boolean, default: false
  end
end
