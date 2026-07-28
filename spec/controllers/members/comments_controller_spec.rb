require "spec_helper"

describe Members::CommentsController do
  include AuthHelper

  let(:member) { create :member }
  let(:application) { create :application }

  describe "GET index" do
    subject { get :index }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]
  end

  describe "POST create" do
    let(:params) {
      {
        user_id: member.id,
        application_id: application.id
      }
    }

    subject { post :create, params: params }

    it_should_behave_like "deny non-members", [:visitor, :applicant]

    context "when logged in as a member" do
      before do
        login_as(member)
      end

      context "with a valid comment" do
        let(:params) {
          {
            comment: {application_id: application.id, body: "test body"},
            application_id: application.id,
            user_id: member.id
          }
        }

        it "creates a comment" do
          subject
          expect(Comment.last.application_id).to eq application.id
          expect(Comment.last.user_id).to eq member.id
          expect(Comment.last.body).to eq "test body"
        end
      end

      context "with an invalid comment" do
        let(:params) {
          {
            comment: {application_id: application.id, body: nil},
            application_id: application.id,
            user_id: member.id
          }
        }

        it "does not create a comment" do
          subject
          expect(Comment.last).to be_nil
        end
      end
    end
  end
end
