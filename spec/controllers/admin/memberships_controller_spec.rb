require "spec_helper"

describe Admin::MembershipsController do
  include AuthHelper

  describe "GET index" do
    context "when logged in as an admin" do
      before { login_as(:voting_member, is_admin: true) }

      context "as HTML" do
        it "allows admin to view admin members index" do
          get :index, format: "html"
          expect(response).to render_template :index
        end
      end

      context "as JSON" do
        let!(:member) { create(:member, name: "Several Lemurs") }
        let(:summary) { "We're like cats and bears mixed together and cute." }

        before { member.profile.update_column(:summary, summary) }

        it "allows admin to view members as json" do
          get :index, format: "json"
          expect(response.body).to include "Several Lemurs"
          expect(response.body).to include summary
        end
      end
    end

    context "logged in as a non-admin" do
      before { login_as(:member) }

      context "as HTML" do
        it "should redirect to root if logged in as member" do
          get :index, format: "html"
          expect(response).to redirect_to :root
        end
      end

      context "as JSON" do
        it "should redirect to root if logged in as member" do
          get :index, format: "json"
          expect(response).to redirect_to :root
        end
      end
    end
  end

  describe "PATCH approve_scholarship" do
    subject { patch :approve_or_continue_scholarship, params: params }
    before { login_as(:member, is_admin: true) }

    context "mark any member not on scholarship as on scholarship" do
      let(:member) { create :member }
      let(:params) { {id: member.id} }

      it "should set scholarship_since and last_checkin" do
        expect { subject }.to change { member.reload.scholarship_since }.from(nil).to be_within(1.second).of Time.now
        expect(member.scholarship_last_checkin).to be_within(1.second).of Time.now
      end
    end

    context "mark a scholarship member as continuing scholarship" do
      let(:member) { create :member, scholarship_since: Time.now }
      let(:params) { {id: member.id} }

      it "should set scholarship_since and last_checkin" do
        expect { subject }.not_to change { member.reload.scholarship_since }
        expect(member.scholarship_last_checkin).to be_within(1.second).of Time.now
      end
    end
  end

  describe "PATCH remove_scholarship" do
    subject { patch :remove_scholarship, params: params }
    before { login_as(:member, is_admin: true) }

    context "mark member requesting scholarship as rejected" do
      let(:member) { create :member, requested_scholarship: Time.now}
      let(:params) { {id: member.id} }

      it "should remove scholarship request" do
        expect { subject }.to change { member.reload.requested_scholarship }.to be_nil
      end
    end

    context "marking a member as not on scholarship" do
      let(:member) { create :member, scholarship_since: Time.now}
      let(:params) { {id: member.id} }

      it "should mark scholarship as false" do
        expect { subject }.to change { member.reload.scholarship_since }.to be_nil
        expect(member.scholarship_last_checkin).to be_nil
      end
    end
  end

  describe "PATCH change_membership_state" do
    subject { patch :change_membership_state, params: params }

    context "logged in as a non-admin" do
      let(:member) { create :member }
      let(:params) { {id: member.id, user: {updated_state: "key_member"}} }

      before { login_as(:member) }

      it "should redirect to root" do
        expect(subject).to redirect_to :root
      end
    end

    context "logged in as an admin" do
      before { login_as(:voting_member, is_admin: true) }

      context "updating member state" do
        let(:params) { {id: member.id, user: {updated_state: updated_state}} }

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
            expect { subject }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end

  describe "PATCH make_admin" do
    subject { patch :make_admin, params: params }

    context "logged in as an admin" do
      before { login_as(:voting_member, is_admin: true) }

      context "making a member an admin" do
        let(:params) { {id: member.id} }
        let(:member) { create :member }

        it "makes them an admin" do
          expect(member.is_admin).to eq false
          subject
          expect(member.reload.is_admin).to eq true
        end
      end
    end

    context "logged in as a non-admin" do
      before { login_as(:voting_member, is_admin: false) }

      context "making a member an admin" do
        let(:params) { {id: member.id, user: {updated_state: updated_state}} }
        let(:member) { create :member }

        let(:updated_state) { "key_member" }

        it "redirect to root and does not update the user" do
          expect { subject }.not_to change { member.is_admin }
          expect(subject).to redirect_to :root
        end
      end
    end
  end

  describe "PATCH unmake_admin" do
    subject { patch :unmake_admin, params: params }

    context "logged in as an admin" do
      before { login_as(:voting_member, is_admin: true) }

      context "making a member an admin" do
        let(:params) { {id: member.id} }
        let(:member) { create :member, is_admin: true }

        it "makes member not an admin" do
          expect(member.is_admin).to eq true
          subject
          expect(member.reload.is_admin).to eq false
        end
      end
    end

    context "logged in as a non-admin" do
      before { login_as(:voting_member, is_admin: false) }

      context "making a member an admin" do
        let(:params) { {id: member.id} }
        let(:member) { create :member }

        let(:updated_state) { "key_member" }

        it "redirect to root and does not update the user" do
          expect { subject }.not_to change { member.is_admin }
          expect(subject).to redirect_to :root
        end
      end
    end
  end
end
