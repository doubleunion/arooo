require 'spec_helper'

describe AdminController do
  include AuthHelper

  describe 'as an admin user' do
    let(:an_application) { create(:application) }

    describe 'GET applications' do
      it 'allows user to view admin applications index' do
        login_as(:key_member, is_admin: true)
        get :applications
        response.should render_template :applications
      end
    end

    describe 'PATCH approve' do
      describe 'with good params' do
        let(:application_params) { { application: { id: an_application.id} } }

        it 'should approve the relevant application' do
          login_as(:key_member, is_admin: true)
          expect do
            patch :approve, application_params
          end.to change { an_application.reload.state }.from("submitted").to("approved")
        end
      end
    end

    describe 'PATCH reject' do
      let(:application_params) { { application: { id: an_application.id} } }

      it 'should reject the relevant application' do
        login_as(:key_member, is_admin: true)
        expect do
          patch :reject, application_params
        end.to change { an_application.reload.state }.from("submitted").to("rejected")
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
  end
end
