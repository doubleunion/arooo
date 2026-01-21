require "spec_helper"

describe AdminController do
  include AuthHelper

  describe "as an admin user" do
    let!(:an_application) { create(:application) }

    describe "GET applications" do
      it "allows user to view admin applications index" do
        login_as(:voting_member, is_admin: true)
        get :applications
        expect(response).to render_template :applications
      end
    end

    describe "PATCH approve" do
      subject { patch :approve, params: {application: {id: an_application.id}} }

      before(:each) do
        # Shortcircuit actually mailing the approval email
        allow(ApplicationsMailer).to receive_message_chain(:approved, :deliver_now)

        login_as(:voting_member, is_admin: true)
      end

      describe "with valid params" do
        it "should approve the relevant application" do
          expect {
            subject
          }.to change { an_application.reload.state }.from("submitted").to("approved")
        end

        it "sends a flash message" do
          subject
          expect(flash[:message]).to be_present
        end
      end

      describe "with invalid params" do
        before(:each) do
          allow_any_instance_of(Application).to receive(:save).and_return(false)
        end

        it "renders applications" do
          subject
          expect(response).to render_template :applications
        end

        it "sends a flash error" do
          subject
          expect(flash[:error]).to be_present
        end
      end
    end

    describe "PATCH reject" do
      subject { patch :reject, params: {application: {id: an_application.id}} }

      before(:each) do
        login_as(:voting_member, is_admin: true)
      end

      describe "with valid params" do
        it "should reject the relevant application" do
          expect {
            subject
          }.to change { an_application.reload.state }.from("submitted").to("rejected")
        end

        it "sends a flash message" do
          subject
          expect(flash[:message]).to be_present
        end
      end

      describe "with invalid params" do
        before(:each) do
          allow_any_instance_of(Application).to receive(:save).and_return(false)
        end

        it "renders applications" do
          subject
          expect(response).to render_template :applications
        end

        it "sends a flash error" do
          subject
          expect(flash[:error]).to be_present
        end
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

      subject { post :setup_complete, params: {user: {id: member.id}} }

      before(:each) do
        member.update(email_for_google: "bananas@example.com")
        login_as(:voting_member, is_admin: true)
      end

      context "with valid parameters" do
        it "allows the admin to mark user setup as complete" do
          expect { subject }.to change { member.reload.setup_complete }.from(nil).to(true)
        end
      end

      context "with an invalid user" do
        before(:each) do
          allow_any_instance_of(User).to receive(:save).and_return(false)
        end

        it "sends a flash message" do
          subject
          expect(flash[:message]).to be_present
        end
      end
    end

    describe "POST add_membership_note" do
      let!(:member) { create(:member) }
      let(:params) { {user: {id: member.id, membership_note: "beeeep"}} }

      subject { post :save_membership_note, params: params }

      before(:each) do
        login_as(:voting_member, is_admin: true)
      end

      context "with valid params" do
        it "allows the admin to make notes on the new user" do
          expect {
            subject
          }.to change { member.reload.membership_note }.from(nil).to("beeeep")
        end
      end

      context "with an invalid user" do
        before(:each) do
          allow_any_instance_of(User).to receive(:save).and_return(false)
        end

        it "sends a flash message" do
          subject
          expect(flash[:notice]).to be_present
        end
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
