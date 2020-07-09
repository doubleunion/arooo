require "spec_helper"

describe SessionsController do
  include UserWithOmniauth
  include AuthHelper

  describe "GET login" do
    it "succeeds" do
      expect(get(:login)).to be_successful
    end

    it "renders the page" do
      expect(get(:login)).to render_template :login
    end
  end

  describe "GET github" do
    it "redirects to github" do
      expect(get(:github)).to redirect_to "/auth/github"
    end
  end

  describe "GET google" do
    it "redirects to github" do
      expect(get(:google)).to redirect_to "/auth/google_oauth2"
    end
  end

  describe "GET create" do
    before do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
    end

    subject { get :create, params: { provider: "github" } }

    describe "for a new user" do
      it "redirects to email confirmation step" do
        expect(subject).to redirect_to get_email_path
      end

      it "sets omniauth info in cookies" do
        subject
        expect(session["uid"]).to eq("12345")
        expect(session["username"]).to eq("someone")
        expect(session["provider"]).to eq("github")
      end
    end

    describe "with an existing user" do
      let(:user) { create_with_omniauth(OmniAuth.config.mock_auth[:github]) }

      context "who is a visitor" do
        it "doesn't make a new user" do
          expect { subject }.to_not change { User.count }
        end

        it "makes the visitor an applicant" do
          expect { subject }.to change { user.reload.state }.from("visitor").to("applicant")
        end

        it "redirects to confirm their email address" do
          subject
          expect(response).to redirect_to get_email_path
        end

        it "does not create a session for them" do
          expect { subject }.not_to change { session[:user_id] }
        end
      end

      context "who is an applicant" do
        before { user.update_attribute(:state, "applicant") }

        it "doesn't make a new user" do
          expect { subject }.to_not change { User.count }
        end

        it "creates a session" do
          subject
          expect(session[:user_id]).to eq(user.id)
        end

        it "redirects to the application edit page" do
          subject
          expect(response).to redirect_to edit_application_path(user.application)
        end
      end

      context "who is a member" do
        before { user.update_attribute(:state, "member") }

        it "doesn't make a new user" do
          expect { subject }.to_not change { User.count }
        end

        it "creates a session" do
          subject
          expect(session[:user_id]).to eq(user.id)
        end

        it "redirects to the member root path" do
          subject
          expect(response).to redirect_to members_root_path
        end

        it "creates session for member" do
          expect { subject }.to_not change { User.count }
          expect(session[:user_id]).to eq(user.id)
        end

        context "who is already logged in" do
          let(:auth) { create :authentication, user: user }

          before do
            login_as(user)
          end

          it "redirects to the member root path" do
            subject
            expect(response).to redirect_to members_root_path
          end
        end
      end
    end

    describe "with an existing, logged-in user" do
      let(:user) { create_with_omniauth(OmniAuth.config.mock_auth[:github]) }

      subject { get :create, params: { provider: "google_oauth2" } }

      before do
        log_in(user)
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
      end

      it "creates a new authentication for the user" do
        expect { subject }.to change { user.authentications.count }.from(1).to(2)
      end

      it "makes a new Google authentication" do
        subject
        expect(user.authentications.last.provider).to eq "google_oauth2"
      end

      it "prints the thing again" do
        subject
      end
    end
  end

  describe "GET get_email" do
    it "renders the get_email page" do
      expect(get(:get_email)).to render_template :get_email
    end
  end

  describe "POST confirm_email" do
    before do
      session[:username] = "coolcat423"
      session[:provider] = "github"
      session[:uid] = "12345"
    end

    subject { post :confirm_email, params: { email: email } }

    context "with valid params" do
      let(:email) { "someone@foo.bar" }

      context "with a new user" do
        let(:user) { User.last }
        let(:authentication) { user.authentications.first }

        it "creates user and makes applicant" do
          expect { subject }.to change { User.count }.from(0).to(1)

          expect(user.applicant?).to be_truthy

          expect(user.username).to be_present
          expect(authentication.provider).to be_present
          expect(authentication.uid).to be_present
        end

        it "sets the session with the newly-created user" do
          subject
          expect(session[:user_id]).to eq(user.id)
        end
      end

      context "with an existing user" do
        let(:user) { create_with_omniauth(OmniAuth.config.mock_auth[:github]) }

        before do
          user.update_attribute(:state, "member")
        end

        it "does not create a user" do
          expect { subject }.not_to change { User.count }
        end

        it "does not set the session" do
          subject
          expect(session[:user_id]).to be_nil
        end

        it "redirects to the root path" do
          expect(subject).to redirect_to :root
        end

        it "sets the flash message" do
          subject
          expect(flash[:alert]).to include "It looks like you've previously logged in"
        end
      end
    end

    context "with a bad email address" do
      let(:email) { "someone" }

      it "rerenders the page" do
        expect(subject).to render_template :get_email
      end

      it "does not set the session" do
        subject
        expect(session[:user_id]).to be_nil
      end
    end

    context "with no email address" do
      let(:email) { "" }

      it "rerenders the page" do
        expect(subject).to render_template :get_email
      end

      it "does not set the session" do
        subject
        expect(session[:user_id]).to be_nil
      end
    end
  end
end
