require "spec_helper"

describe Members::ApplicationsController do
  include AuthHelper

  render_views

  before :each do
    @applicant = create(:user, state: :applicant)
  end

  describe "GET index" do
    before :each do
      login_as(:voting_member)
    end

    it "returns a local with a list of not sponsored applicant emails" do
      unsponsored_application = create(:application)
      get :index
      expect(assigns(:emails_with_no_sponsors)).to eq([unsponsored_application.user.email])
    end

    it "returns a local with a list of sponsored applicant emails" do
      sponsored_application = create(:application)
      create(:sponsorship, application: sponsored_application)
      get :index
      expect(assigns(:emails_with_sponsors)).to eq([sponsored_application.user.email])
    end
  end

  describe "GET show" do
    it "redirects if not logged in" do
      get :show, params: {id: @applicant.application.id}
      expect(response).to redirect_to :root
    end

    it "redirects if logged in as visitor" do
      login_as(:visitor)
      get :show, params: {id: @applicant.application.id}
      expect(response).to redirect_to :root
    end

    it "redirects if logged in as applicant" do
      login_as(@applicant)
      get :show, params: {id: @applicant.application.id}
      expect(response).to redirect_to :root
    end

    describe "for authenticated member" do
      it "redirects if application is in started state" do
        login_as(:member)
        get :show, params: {id: @applicant.application.id}
        expect(flash[:error]).to match(/not currently visible/)
        expect(response).to redirect_to members_root_path
      end

      it "renders if application is in submitted state" do
        login_as(:member)

        applicant = create(:user, state: :applicant)
        application = applicant.application
        application.update_attribute(:state, "submitted")

        get :show, params: {id: application.id}
        expect(response).to render_template :show
      end

      it "redirects if application is in approved state" do
        login_as(:member)

        applicant = create(:user, state: :applicant)
        application = applicant.application
        application.update_attribute(:state, "approved")

        get :show, params: {id: application.id}
        expect(response).to redirect_to members_root_path
      end

      it "redirects if application is in rejected state" do
        login_as(:member)

        applicant = create(:user, state: :applicant)
        application = applicant.application
        application.update_attribute(:state, "rejected")

        get :show, params: {id: application.id}
        expect(response).to redirect_to members_root_path
      end

      context "when viewed by a voting member" do
        let(:submitted_application) { create(:application, state: "submitted") }
        let!(:comments) { create_list(:comment, 2, application: submitted_application) }

        before do
          login_as(:voting_member)
        end

        it "shows all the comments" do
          get :show, params: {id: submitted_application.id}
          expect(response).to render_template :show
          expect(assigns(:comments)).to eq(comments)
        end
      end

      context "when viewed by a non-voting member" do
        let(:member) { create(:member) }
        let!(:comment_by_self) { create(:comment, user: member, application: submitted_application) }
        let!(:comment_by_someone_else) { create(:comment, application: submitted_application) }
        let(:submitted_application) { create(:application, state: "submitted") }

        before do
          login_as(member)
        end

        it "shows only comments authored by the current logged in member" do
          get :show, params: {id: submitted_application.id}
          expect(assigns(:comments)).to include(comment_by_self)
          expect(assigns(:comments)).to_not include(comment_by_someone_else)
        end
      end
    end

    describe "for submitted application" do
      before :each do
        @submitted_application = create(:user, state: :applicant).application
        @submitted_application.update_attribute(:state, "submitted")
      end

      it "does not render voting form for member" do
        login_as(:member)
        get :show, params: {id: @submitted_application.id}
        expect(response).to render_template :show
        expect(response.body).not_to have_selector(:css, "form#new_vote")
      end

      it "renders voting form for voting member" do
        login_as(:voting_member)
        get :show, params: {id: @submitted_application.id}
        expect(response).to render_template :show
        expect(response.body).to have_selector(:css, "form#new_vote")
      end
    end
  end
end
