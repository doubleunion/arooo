require 'spec_helper'

describe Admin::AdminController do

  describe 'GET index' do
    it 'redirects if not logged in' do
      get :index
      response.should redirect_to :root
    end

    it 'redirects if logged in as visitor' do
      user = User.make!
      controller.stub(:current_user).and_return(user)
      get :index
      response.should redirect_to :root
    end

    it 'redirects if logged in as applicant' do
      user = User.make!(:state => 'applicant')
      controller.stub(:current_user).and_return(user)
      get :index
      response.should redirect_to :root
    end

    it 'renders if logged in as member' do
      user = User.make!(:state => 'member')
      controller.stub(:current_user).and_return(user)
      get :index
      response.should be_success
    end

    it 'renders if logged in as key member' do
      user = User.make!(:state => 'key_member')
      controller.stub(:current_user).and_return(user)
      get :index
      response.should be_success
    end
  end

end
