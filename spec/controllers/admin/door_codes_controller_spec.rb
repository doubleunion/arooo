# frozen_string_literal: true

require 'spec_helper'

describe Admin::DoorCodesController do
  include AuthHelper

  render_views

  let(:door_code) { create(:door_code) }
  let(:params) { { id: door_code.id } }

  describe "GET :index" do
    context "logged in as a non-admin member" do
      before { login_as(:member) }

      it "redirects to root" do
        get :index
        expect(response).to redirect_to :root
      end
    end

    context "when logged in as an admin" do
      let!(:door_codes) { create_list(:door_code, 5)}

      before { login_as(:voting_member, is_admin: true) }

      it "shows the index" do
        get :index

        door_codes.each do |door_code|
          expect(response.body).to include(door_code.code)
          expect(response.body).to include(door_code.status.to_s)
        end
      end
    end
  end

  describe "POST :create" do
    context "when logged in as an admin" do
      let!(:existing_member) { create(:member) }
      let!(:existing_door_code) { create(:door_code) }

      before { login_as(:voting_member, is_admin: true) }

      it "saves the new door code" do
        expect {
          post :create, params: { door_code: { code: "1234567", status: "in_lock", user_id: existing_member.id } }
        }.to change(DoorCode, :count).from(1).to(2)
        expect(existing_member.door_code.code).to eq("1234567")
      end

      it "doesn't save a duplicated door code" do
        expect {
          post :create, params: { door_code: { code: existing_door_code.code, status: "in_lock" } }
        }.to_not change(DoorCode, :count)
      end
    end
  end
end
