require "spec_helper"

describe Members::VotingMembersController do
  include AuthHelper

  let(:member) { create :member }

  describe "get edit" do
    let(:subject) { get :edit, params: { user_id: member } }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :key_member]

    context "logged in as a member" do
      before { login_as member }

      it "allows members to load the status edit form" do
        subject
        expect(response).to be_successful
        expect(response).to render_template :edit
      end
    end
  end

  describe "post update" do
    let(:subject) { patch :update, params: { user_id: member } }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :key_member]

    context "logged in as a member" do
      before { login_as member }

      context "with the agreement boxes checked" do
        let(:params) {
          {
            "user_id" => member.id,
            "agreements" => {
              "confidentiality" => "1", "attended_training" => "1", "policy_agreement" => "1",
              "time_commitment" => "1", "voting_principles" => "1", "hard_conversations" => "1"
            }
          }
        }

        let(:subject) { patch :update, params: params }

        it "marks the member as having agreed to the voting member policies" do
          expect { subject }.to change { member.reload.voting_policy_agreement }.from(false).to(true)
        end

        it "renders the members index with a flash" do
          subject
          expect(response).to redirect_to members_root_path
          expect(flash[:message]).to include "Thank you for volunteering to serve as a voting member! A membership coordinator will be in touch soon."
        end
      end

      context "with the agreement boxes unchecked" do
        let(:params) {
          {
            "user_id" => member.id,
            "agreements" => {"confidentiality" => "1"}
          }
        }

        let(:subject) { patch :update, params: params }

        it "does not set the voting policy agreement" do
          expect { subject }.not_to change { member.voting_policy_agreement }.from(false)
        end

        it "rerenders the form with a flash" do
          subject
          expect(response).to render_template :edit
          expect(flash[:error]).to include "You must agree to the statements below to become a voting member."
        end
      end
    end
  end
end
