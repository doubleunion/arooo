require 'spec_helper'

describe ApplicationsController do
  include AuthHelper

  describe 'GET new' do
    it 'should redirect to root if not logged in' do
      get :new
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      login_as(:visitor)
      get :new
      expect(response).to redirect_to :root
    end

    it 'should redirect to edit if logged in as applicant' do
      user = login_as(:applicant)
      get :new
      expect(response).to redirect_to edit_application_path(user.application)
    end

    it 'should redirect to root if logged in as member' do
      login_as(:member)
      get :new
      expect(response).to redirect_to :root
    end
  end

  describe 'GET show' do
    it 'should redirect to root if not logged in' do
      get :show, id: 1
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      user = login_as(:visitor)
      get :show, id: user.application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as member' do
      user = login_as(:member)
      get :show, id: user.application.id
      expect(response).to redirect_to :root
    end

    describe 'if logged in as applicant' do
      let(:user) { create :applicant }
      let(:other_user) { create :applicant }

      before { log_in(user) }

      it 'should render own application' do
        get :show, id: user.application.id
        expect(response).to render_template :show
      end

      it 'should not render application of another user' do
        get :show, id: other_user.application.id
        expect(response).to redirect_to :root
      end
    end
  end

  describe 'GET edit' do
    it 'should redirect to root if not logged in' do
      get :edit, id: User.make!(:applicant).application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      user = login_as(:visitor)
      get :edit, id: user.application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as member' do
      user = login_as(:member)
      get :edit, id: user.application.id
      expect(response).to redirect_to :root
    end

    describe 'if logged in as applicant' do
      let(:user) { create :applicant }
      let(:other_user) { create :applicant }

      before { log_in(user) }

      it 'should render edit for own application' do
        get :edit, id: user.application.id
        expect(response).to render_template :edit
      end

      it "should redirect to root for another user's application" do
        get :edit, id: other_user.application.id
        expect(response).to redirect_to :root
      end
    end
  end

  describe 'POST update' do
    it 'should redirect to root if not logged in' do
      post :update, id: User.make!(:applicant).application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      user = login_as(:visitor)
      post :update, id: user.application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as member' do
      user = login_as(:member)
      post :update, id: user.application.id
      expect(response).to redirect_to :root
    end

    describe 'if logged in as applicant' do
      it 'should update own application' do
        user = login_as(:applicant)
        expect(user.application.agreement_terms).to be_falsey

        params = { id: user.application.id, user: {
          application_attributes:
            { id: user.application.id, agreement_terms: true }
          }
        }

        post :update, params

        expect(response).to redirect_to edit_application_path(user.application)

        expect(user.application.agreement_terms).to be_truthy
      end
    end
  end
end
