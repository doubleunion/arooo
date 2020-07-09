require "spec_helper"

describe Members::KeyMembersController do
  include AuthHelper

  let(:member) { create :member }

  describe "get edit" do
    let(:subject) { get :edit, params: { user_id: member } }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

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
    it_should_behave_like "allow members", [:member, :voting_member]

    context "logged in as a member" do
      before { login_as member }

      context "with the agreement boxes checked" do
        let(:params) {
          {
            "user_id" => member.id,
            "agreements" => {"attended_events" => "1", "kick_out" => "1", "lock_up" => "1", "take_action" => "1"}
          }
        }

        let(:subject) { patch :update, params: params }

        it "marks the member as a key member" do
          expect { subject }.to change { member.state }.from("member").to("key_member")
        end

        it "emails the chatelaine and membership coordinators" do
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        it "renders the members index with a flash" do
          subject
          expect(response).to redirect_to members_root_path
          expect(flash[:message]).to include "Yay, you're now a key member!"
        end
      end

      context "with the agreement boxes unchecked" do
        let(:params) {
          {
            "user_id" => member.id,
            "agreements" => {"lock_up" => "1", "take_action" => "1"}
          }
        }

        let(:subject) { patch :update, params: params }

        it "does not send any emails" do
          expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
        end

        it "does not change the member's status" do
          expect { subject }.not_to change { member.state }.from("member")
        end

        it "rerenders the form with a flash" do
          subject
          expect(response).to render_template :edit
          expect(flash[:error]).to include "You must agree to the statements below to become a key member."
        end
      end
    end

    context "logged in as a key member" do
      let(:member) { create :key_member }

      it "does not send any emails" do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end

      it "does not change the member's status" do
        expect { subject }.not_to change { member.state }.from("key_member")
      end
    end
  end
end
