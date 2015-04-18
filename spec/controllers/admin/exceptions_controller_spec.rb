require "spec_helper"

describe Admin::ExceptionsController do
  include AuthHelper

  context "logged in as an admin" do
    before { login_as(:voting_member, is_admin: true) }

    it "raises an exception" do
      expect { get :show }.to raise_error
    end
  end
end
