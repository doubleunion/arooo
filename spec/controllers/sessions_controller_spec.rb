require 'spec_helper'

describe SessionsController do
  describe 'GET new' do
    it 'redirects to github' do
      get :new
      response.should redirect_to('/auth/github')
    end
  end

  describe 'GET create' do
    before :each do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:github]
    end

    describe 'for new user' do
      it 'creates user in visitor state' do
        expect {
          get :create, :provider => 'github'
        }.to change { User.count }.from(0).to(1)

        user = User.last
        user.visitor?.should be_true

        user.uid.should      be_present
        user.username.should be_present
        user.provider.should be_present

        session[:user_id].should eq(user.id)
      end
    end

    describe 'for existing user' do
      it 'creates session for visitor' do
        user = User.create_with_omniauth(OmniAuth.config.mock_auth[:github])

        expect {
          get :create, :provider => 'github'
        }.to_not change { User.count }

        user.visitor?.should be_true

        session[:user_id].should eq(user.id)
      end

      it 'creates session for member' do
        user = User.create_with_omniauth(OmniAuth.config.mock_auth[:github])
        user.update_attribute(:state, 'member')

        expect {
          get :create, :provider => 'github'
        }.to_not change { User.count }

        user.member?.should be_true

        session[:user_id].should eq(user.id)
      end

      it 'creates session for provisioned member' do
        username = OmniAuth.config.mock_auth[:github][:extra][:raw_info][:login]
        user = nil
        expect {
          user = User.provision_with_state(username, 'member')
        }.to change { User.count }.from(0).to(1)

        expect {
          get :create, :provider => 'github'
        }.to_not change { User.count }

        user.member?.should be_true

        session[:user_id].should eq(user.id)
      end
    end
  end
end
