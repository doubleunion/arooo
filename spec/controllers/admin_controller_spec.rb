require 'spec_helper'

describe AdminController do
  include AuthHelper

  describe 'as an admin user' do
    let(:an_application) { create(:application) }

    describe 'GET applications' do
      it 'allows user to view admin applications index' do
        login_as(:voting_member, is_admin: true)
        get :applications
        response.should render_template :applications
      end
    end

    describe 'PATCH approve' do
      describe 'with good params' do
        let(:application_params) { { application: { id: an_application.id} } }

        it 'should approve the relevant application' do
          login_as(:voting_member, is_admin: true)
          expect do
            patch :approve, application_params
          end.to change { an_application.reload.state }.from("submitted").to("approved")
        end
      end
    end

    describe 'PATCH reject' do
      let(:application_params) { { application: { id: an_application.id} } }

      it 'should reject the relevant application' do
        login_as(:voting_member, is_admin: true)
        expect do
          patch :reject, application_params
        end.to change { an_application.reload.state }.from("submitted").to("rejected")
      end
    end

    describe 'GET new_members' do
      it 'allows admin to view admin new members index' do
        login_as(:voting_member, is_admin: true)
        get :new_members
        response.should render_template :new_members
      end
    end

    describe 'POST setup_complete' do
      let!(:member) { create(:member) }
      let(:params) { { user: { id: member.id} } }

      it 'allows the admin to mark user setup as complete' do
        login_as(:voting_member, is_admin: true)
        post :setup_complete, params
        expect {member.reload.setup_complete}.to be_true
      end
    end

    describe 'POST add_membership_note' do
      let!(:member) { create(:member) }
      let(:params) { { user: { id: member.id, membership_note: "beeeep"} } }

      it 'allows the admin to make notes on the new user' do
        login_as(:voting_member, is_admin: true)
        expect do
          post :save_membership_note, params
        end.to change{member.reload.membership_note}.from(nil).to("beeeep")
      end

    end

    describe 'GET members' do
      context 'as HTML' do
        it 'allows admin to view admin members index' do
          login_as(:voting_member, is_admin: true)
          get :members, format: 'html'
          response.should render_template :members
        end
      end

      context 'as JSON' do
        let!(:member) { create(:member, name: 'Several Lemurs') }
        let(:summary) { "We're like cats and bears mixed together and cute." }

        before {
          member.profile.update_column(:summary, summary)
        }

        it 'allows admin to view members as json' do
          login_as(:voting_member, is_admin: true)
          get :members, format: 'json'
          response.body.should include "Several Lemurs"
          response.body.should include summary
        end
      end
    end

    describe 'PATCH add_key_member' do
      let(:user) { create(:member) }
      let(:params) { { user: { id: user.id} } }

      it 'allows admin to add key_member access' do
        login_as(:voting_member, is_admin: true)
        expect do
          patch :add_key_member, params
        end.to change { user.reload.state }.from("member").to("key_member")
      end
    end

    describe 'PATCH revoke_key_member' do
      let(:user) { create(:key_member) }
      let(:params) { { user: { id: user.id} } }

      it 'allows admin to revoke key_member access' do
        login_as(:key_member, is_admin: true)
        expect do
          patch :revoke_key_member, params
        end.to change { user.reload.state }.from("key_member").to("member")
      end
    end

    describe 'PATCH add_voting_member' do
      let(:user) { create(:member) }
      let(:params) { { user: { id: user.id} } }

      it 'allows admin to add voting_member access' do
        login_as(:voting_member, is_admin: true)
        expect do
          patch :add_voting_member, params
        end.to change { user.reload.state }.from("member").to("voting_member")
      end
    end

    describe 'PATCH revoke_voting_member' do
      let(:user) { create(:voting_member) }
      let(:params) { { user: { id: user.id} } }

      it 'allows admin to revoke voting_member access' do
        login_as(:voting_member, is_admin: true)
        expect do
          patch :revoke_voting_member, params
        end.to change { user.reload.state }.from("voting_member").to("key_member")
      end
    end

    describe 'PATCH revoke_membership' do
      let(:user) { create(:member) }
      let(:params) { { user: { id: user.id } } }

      it 'allows admin to revoke membership' do
        login_as(:voting_member, is_admin: true)
        expect do
          patch :revoke_membership, params
        end.to change { user.reload.state }.from("member").to("former_member")
      end
    end

    describe 'GET dues' do
      it "allows admins to view the admin dues page" do
        login_as(:voting_member, is_admin: true)
        get :dues
        expect(response).to render_template :dues
        expect(assigns(:all_members)).to eq(User.all_members)
      end
    end
  end

  describe 'as a non-admin user' do
    describe 'GET applications' do
      it 'should redirect to root if logged in as member' do
        login_as(:member)
        get :applications
        response.should redirect_to :root
      end
    end

    describe 'GET members' do
      context 'as HTML' do
        it 'should redirect to root if logged in as member' do
          login_as(:member)
          get :members, format: 'html'
          response.should redirect_to :root
        end
      end

      context 'as JSON' do
        it 'should redirect to root if logged in as member' do
          login_as(:member)
          get :members, format: 'json'
          response.should redirect_to :root
        end
      end
    end

    describe 'GET dues' do
      it 'should redirect to root if logged in as member' do
        login_as(:member)
        get :dues
        response.should redirect_to :root
      end
    end
  end
end
