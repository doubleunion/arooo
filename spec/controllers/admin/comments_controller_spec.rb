require 'spec_helper'

describe Admin::CommentsController do
  include AuthHelper

  render_views

  describe 'PUT create' do

    before do
      login_as(:member)
    end

    context "with valid params" do
      let(:comment_params) { { comment: "This is a comment" } }
      let(:new_comment_text) { Application.last.comments.last.comment }

      it "adds a new comment" do
        put :create, application_id: Application.last, comment: comment_params
        expect(new_comment_text).to eq("This is a comment")
        expect(Comment.count).to eq(1)
      end
    end

    context "with invalid params" do
      let(:comment_params) { { comment: ""} }

      it "doesn't add an empty comment" do
        put :create, application_id: Application.last, comment: comment_params
        expect(Comment.count).to eq(0)
      end
    end
  end
end
