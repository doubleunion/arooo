require "spec_helper"

describe Members::UsersController do
  include AuthHelper

  let(:someone_cool) { create(:member) }

  describe "GET index" do
    subject { get :index }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it "redirects if not logged in" do
      subject
      expect(response).to redirect_to :root
    end
  end

  describe "GET show" do
    subject { get :show, params: { id: someone_cool.id } }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it "redirects if not logged in" do
      subject
      expect(response).to redirect_to :root
    end
  end

  describe "GET edit" do
    subject { get :edit, params: { id: someone_cool.id } }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it "redirects if not logged in" do
      subject
      expect(response).to redirect_to :root
    end
  end

  describe "POST update" do
    subject { post :update, params: { id: someone_cool.id, user: {id: someone_cool.id} } }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it "redirects if not logged in" do
      subject
      expect(response).to redirect_to :root
    end

    describe "updating stuff" do
      context "when logged in" do
        it "updates name and email" do
          user = login_as(:member, name: "Foo Bar", email: "someone@foo.bar")

          post :update, params: {
            id: user.id,
            user: {
              name: "FooBar TooBar",
              email: "someone2@foo.bar",
              pronounceable_name: "Mouse",
              profile_attributes: {skills: "writing awesome tests"}
            }
          }

          expect(response).to render_template :edit

          expect(user.name).to eq("FooBar TooBar")
          expect(user.email).to eq("someone2@foo.bar")
          expect(user.pronounceable_name).to eq("Mouse")
          expect(user.profile.skills).to eq("writing awesome tests")
        end
      end

      context "when not logged in as particular user" do
        it "updates your own info instead of theirs" do
          member = login_as(:member)

          post :update, params: {
            id: someone_cool.id,
            user: {name: "Little Bobby Tables Was Here"}
          }

          expect(someone_cool.name).to eq(someone_cool.reload.name)
          expect(member.name).to eq("Little Bobby Tables Was Here")
        end
      end
    end
  end

  describe "GET setup" do
    subject { get :setup, params: { user_id: someone_cool.id } }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it "redirects if not logged in" do
      subject
      expect(response).to redirect_to :root
    end
  end

  describe "PATCH finalize" do
    subject { patch :finalize, params: { user_id: someone_cool.id, user: {dues_pledge: 25} } }

    it_should_behave_like "deny non-members", [:visitor, :applicant]

    it "updates Google email and dues pledge if logged in" do
      user = login_as(:member, name: "Foo Bar", email: "someone@foo.bar")

      patch :finalize, params: {
        user_id: user.id,
        user: {
          dues_pledge: 25,
          email_for_google: "googly-eyes@example.com"
        }
      }

      expect(response).to render_template "setup"

      expect(user.dues_pledge).to eq(25)
      expect(user.email_for_google).to eq("googly-eyes@example.com")
    end
  end
end
