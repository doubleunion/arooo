require 'spec_helper'

describe Members::UsersController do
  include AuthHelper

  let(:someone_cool) { create(:member) }

  shared_examples "deny non-members" do |folks|
    folks.each do |folk|
      it "should deny non-members" do
        login_as(folk)
        subject
        expect(response).to redirect_to :root
      end
    end
  end

  shared_examples "allow members" do |folks|
    folks.each do |folk|
      it "should allow members" do
        login_as(folk)
        subject
        expect(response).to be_success
      end
    end
  end

  describe 'GET index' do
    subject { get :index }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :key_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end

  describe 'GET show' do
    subject { get :show, id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :key_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end

  describe 'GET edit' do
    subject { get :edit, id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :key_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end

  describe 'POST update' do
    subject { post :update, id: someone_cool.id, user: {id: someone_cool.id} }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :key_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end

    describe "updating stuff" do
      context "when logged in" do
        it 'updates name and email' do
          user = login_as(:member, :name => 'Foo Bar', :email => 'someone@foo.bar')

          post :update, :id => user.id, :user => {
            name: 'FooBar TooBar',
            email: 'someone2@foo.bar',
            profile_attributes: { skills: 'writing awesome tests' }
          }

          response.should render_template :edit

          user.name.should eq('FooBar TooBar')
          user.email.should eq('someone2@foo.bar')
          user.profile.skills.should eq('writing awesome tests')
        end
      end

      context "when not logged in as particular user" do
        it "updates your own info instead of theirs" do
          member = login_as(:member)

          post :update, id: someone_cool.id, user: { name: 'Little Bobby Tables Was Here' }

          expect(someone_cool.name).to eq(someone_cool.reload.name)
          expect(member.name).to eq("Little Bobby Tables Was Here")
        end
      end
    end
  end

  describe 'GET setup' do
    subject { get :setup, user_id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :key_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end

  describe 'PATCH finalize' do
    subject {  patch :finalize, user_id: someone_cool.id, user: {dues_pledge: 25} }

    it_should_behave_like "deny non-members", [:visitor, :applicant]

    it 'updates Google email and dues pledge if logged in' do
      user = login_as(:member, :name => 'Foo Bar', :email => 'someone@foo.bar')

      patch :finalize, :user_id => user.id, :user => {
        :dues_pledge  => 25,
        :email_for_google => 'googly-eyes@example.com' }

      response.should render_template "setup"

      user.dues_pledge.should eq(25)
      user.email_for_google.should eq('googly-eyes@example.com')
    end
  end

  describe 'GET dues' do
    subject { get :dues, user_id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :key_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end
end
