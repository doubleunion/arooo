require 'spec_helper'

describe UsersController do
  describe 'GET edit' do
    it 'redirects to root if logged out' do
      get :edit
      response.should redirect_to root_path
    end

    it 'renders if logged in' do
      controller.stub(:current_user).and_return(User.make!)
      get :edit
      response.should render_template :edit
    end
  end

  describe 'POST update' do
    it 'redirects to root if logged out' do
      get :edit
      response.should redirect_to root_path
    end

    it 'updates name and email if logged in' do
      user = User.make!(:name => 'Foo Bar', :email => 'someone@foo.bar')
      controller.stub(:current_user).and_return(user)

      post :update, :id => user.id, :user => {
        :name  => 'Foo2 Bar2',
        :email => 'someone2@foo.bar' }

      response.should redirect_to settings_path

      user.name.should eq('Foo2 Bar2')
      user.email.should eq('someone2@foo.bar')
    end
  end
end
