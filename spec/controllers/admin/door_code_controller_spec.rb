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

  describe 'PATCH generate_new_for_user' do
    let(:key_member) { create(:key_member) }

    subject { patch :generate_new_for_user, params: { id: key_member.id } }

    context 'logged in as a non-admin member' do
      before { login_as(:member) }

      it 'redirects to root' do
        subject
        expect(response).to redirect_to :root
      end
    end

    context 'logged in as an admin' do
      before { login_as(:voting_member, is_admin: true) }

      it 'creates a new door code for the user' do
        expect(key_member.door_code).to be_nil
        expect { subject }.to change { DoorCode.count }.by(1)
        key_member.reload
        expect(key_member.door_code).to_not be_nil
      end
    end
  end
end
