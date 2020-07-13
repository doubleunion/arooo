require "spec_helper"

describe AdminController do
  include AuthHelper

  describe "as an admin user" do
    let(:an_application) { create(:application) }

    describe "GET applications" do
      it "allows user to view admin applications index" do
        login_as(:voting_member, is_admin: true)
        get :applications
        expect(response).to render_template :applications
      end
    end

    describe "PATCH approve" do
      describe "with good params" do
        let(:application_params) { {application: {id: an_application.id}} }

        it "should approve the relevant application" do
          login_as(:voting_member, is_admin: true)
          expect {
            patch :approve, params: application_params
          }.to change { an_application.reload.state }.from("submitted").to("approved")
        end
      end
    end

    describe "PATCH reject" do
      let(:application_params) { {application: {id: an_application.id}} }

      it "should reject the relevant application" do
        login_as(:voting_member, is_admin: true)
        expect {
          patch :reject, params: application_params
        }.to change { an_application.reload.state }.from("submitted").to("rejected")
      end
    end

    describe "GET new_members" do
      it "allows admin to view admin new members index" do
        login_as(:voting_member, is_admin: true)
        get :new_members
        expect(response).to render_template :new_members
      end
    end

    describe "POST setup_complete" do
      let!(:member) { create(:member) }
      let(:params) { {user: {id: member.id}} }

      subject { post :setup_complete, params: params }

      before do
        member.update(email_for_google: "bananas@example.com")
      end

      it "allows the admin to mark user setup as complete" do
        login_as(:voting_member, is_admin: true)

        expect { subject }.to change { member.reload.setup_complete }.from(nil).to(true)
      end
    end

    describe "POST add_membership_note" do
      let!(:member) { create(:member) }
      let(:params) { {user: {id: member.id, membership_note: "beeeep"}} }

      it "allows the admin to make notes on the new user" do
        login_as(:voting_member, is_admin: true)
        expect {
          post :save_membership_note, params: params
        }.to change { member.reload.membership_note }.from(nil).to("beeeep")
      end
    end

    describe "GET dues" do
      it "allows admins to view the admin dues page" do
        login_as(:voting_member, is_admin: true)
        get :dues
        expect(response).to render_template :dues
        expect(assigns(:all_members)).to eq(User.all_members)
      end
    end
  end

  describe "as a non-admin user" do
    describe "GET applications" do
      it "should redirect to root if logged in as member" do
        login_as(:member)
        get :applications
        expect(response).to redirect_to :root
      end
    end

    describe "GET dues" do
      it "should redirect to root if logged in as member" do
        login_as(:member)
        get :dues
        expect(response).to redirect_to :root
      end
    end
  end
end
