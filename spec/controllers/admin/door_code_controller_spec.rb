# frozen_string_literal: true

require 'spec_helper'

describe Admin::DoorCodeController do
  include AuthHelper

  let(:door_code) { create(:door_code) }
  let(:params) { { id: door_code.id } }

  describe 'PATCH disable_door_code' do
    subject { patch :disable_door_code, params: params }

    context 'logged in as a non-admin member' do
      before { login_as(:member) }

      it 'redirects to root' do
        subject
        expect(response).to redirect_to :root
      end
    end

    context 'logged in as an admin' do
      before { login_as(:voting_member, is_admin: true) }

      it 'disables the door code' do
        door_code.update_attributes!(enabled: true)
        subject
        door_code.reload
        expect(door_code.enabled).to be false
      end
    end
  end

  describe 'PATCH enable_door_code' do
    subject { patch :enable_door_code, params: params }

    context 'logged in as a non-admin member' do
      before { login_as(:member) }

      it 'redirects to root' do
        subject
        expect(response).to redirect_to :root
      end
    end

    context 'logged in as an admin' do
      before { login_as(:voting_member, is_admin: true) }

      it 'disables the door code' do
        door_code.update_attributes!(enabled: false)
        subject
        door_code.reload
        expect(door_code.enabled).to be true
      end
    end
  end
end
