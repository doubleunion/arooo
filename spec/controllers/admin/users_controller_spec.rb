require 'spec_helper'

describe Admin::UsersController do
  include AuthHelper

  describe 'GET index' do
    it 'redirects if not logged in' do
      get :index
      response.should redirect_to :root
    end

    it 'redirects if logged in as visitor' do
      login_as(:visitor)
      get :index
      response.should redirect_to :root
    end

    it 'redirects if logged in as applicant' do
      login_as(:applicant)
      get :index
      response.should redirect_to :root
    end

    it 'renders if logged in as member' do
      login_as(:member)
      get :index
      response.should be_success
    end

    it 'renders if logged in as key member' do
      login_as(:key_member)
      get :index
      response.should be_success
    end
  end

  describe 'GET show' do
    it 'redirects if not logged in' do
      get :show, :id => User.make!.id
      response.should redirect_to :root
    end

    it 'redirects if logged in as visitor' do
      login_as(:visitor)
      get :index
      response.should redirect_to :root
    end
  end
end
