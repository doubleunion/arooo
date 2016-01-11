class AddVotingPolicyAgreementToUsers < ActiveRecord::Migration
  def change
    add_column :users, :voting_policy_agreement, :boolean, default: false
  end
end
