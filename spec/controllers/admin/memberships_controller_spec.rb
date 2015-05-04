require "spec_helper"

describe Admin::MembershipsController do
  include AuthHelper

  describe "GET index" do
    context "when logged in as an admin" do
      before { login_as(:voting_member, is_admin: true) }

      context "as HTML" do
        it "allows admin to view admin members index" do
          get :index, format: "html"
          response.should render_template :index
        end
      end

      context "as JSON" do
        let!(:member) { create(:member, name: "Several Lemurs") }
        let(:summary) { "We're like cats and bears mixed together and cute." }

        before { member.profile.update_column(:summary, summary) }

        it "allows admin to view members as json" do
          get :index, format: "json"
          response.body.should include "Several Lemurs"
          response.body.should include summary
        end
      end
    end

    context "logged in as a non-admin" do
      before { login_as(:member) }

      context "as HTML" do
        it "should redirect to root if logged in as member" do
          get :index, format: "html"
          response.should redirect_to :root
        end
      end

      context "as JSON" do
        it "should redirect to root if logged in as member" do
          get :index, format: "json"
          response.should redirect_to :root
        end
      end
    end
  end

  describe "PUT update" do
    let(:params) { { id: member.id, user: { updated_state: updated_state } } }

    subject { put :update, params }

    context "logged in as a non-admin" do
      let(:member) { create :member }
      let(:updated_state) { "key_member" }

      before { login_as(:member) }

      it "should redirect to root" do
        expect(subject).to redirect_to :root
      end
    end

    context "logged in as an admin" do
      before { login_as(:voting_member, is_admin: true) }

      context "making a member a key member" do
        let(:member) { create :member }

        let(:updated_state) { "key_member" }

        it "updates their status to key member" do
          expect { subject }.to change { member.reload.state }.from("member").to("key_member")
        end
      end

      context "making a member a voting member" do
        let(:member) { create :member }

        let(:updated_state) { "voting_member" }

        it "updates their status to voting member" do
          expect { subject }.to change { member.reload.state }.from("member").to("voting_member")
        end
      end

      context "revoking someone's membership" do
        let(:member) { create :member }

        let(:updated_state) { "former_member" }

        it "updates their status to former member" do
          expect { subject }.to change { member.reload.state }.from("member").to("former_member")
        end
      end

      context "revoking someone's key membership" do
        let(:member) { create :key_member }

        let(:updated_state) { "member" }

        it "updates their status to member" do
          expect { subject }.to change { member.reload.state }.from("key_member").to("member")
        end
      end

      context "revoking someone's voting membership" do
        let(:member) { create :voting_member }

        let(:updated_state) { "key_member" }

        it "updates their status to key member" do
          expect { subject }.to change { member.reload.state }.from("voting_member").to("key_member")
        end
      end

      context "with an invalid state transition" do
        let(:member) { create :applicant }

        let(:updated_state) { "key_member" }

        it "sets the error in the flash" do
          subject
          expect(flash[:message]).to include "State cannot transition via "
        end
      end

      context "with an invalid state" do
        let(:member) { create :member }

        let(:updated_state) { "bananas" }

        it "raises an error" do
          expect { subject }.to raise_error
        end
      end
    end
  end
end
