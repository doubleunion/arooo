require 'spec_helper'

describe UsersController do
  include AuthHelper

  describe 'GET edit' do
    it 'redirects to root if logged out' do
      get :edit
      response.should redirect_to root_path
    end

    it 'redirects to root if logged in as visitor' do
      login_as(:visitor)
      get :edit
      response.should redirect_to root_path
    end

    it 'redirects to root if logged in as applicant' do
      login_as(:applicant)
      get :edit
      response.should redirect_to root_path
    end

    it 'renders if logged in as member' do
      login_as(:member)
      get :edit
      response.should render_template :edit
    end
  end

  describe 'POST update' do
    it 'redirects to root if logged out' do
      post :update, :id => User.make!.id
      response.should redirect_to root_path
    end

    it 'redirects to root if logged in as visitor' do
      user = login_as(:visitor)
      post :update, :id => user.id
      response.should redirect_to root_path
    end

    it 'redirects to root if logged in as applicant' do
      user = login_as(:applicant)
      post :update, :id => user.id
      response.should redirect_to root_path
    end

    it 'updates name and email if logged in' do
      user = login_as(:member, :name => 'Foo Bar', :email => 'someone@foo.bar')

      post :update, :id => user.id, :user => {
        :name  => 'Foo2 Bar2',
        :email => 'someone2@foo.bar' }

      response.should redirect_to settings_path

      user.name.should eq('Foo2 Bar2')
      user.email.should eq('someone2@foo.bar')
    end
  end
end
