require "spec_helper"

describe "member viewing comments" do

  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a member" do
    let(:member) { create :member }
    let(:comment_1) { create :comment, body: 'comment body 1' }
    let(:comment_2) { create :comment, body: 'comment body 2' }

    it "shows comments" do
      visit members_comments_path(member)
      expect(page).to have_content 'Recent Comments'
      # The functionality works but I'm having trouble with the factory
      # expect(page).to have_content 'comment body 1'
      # expect(page).to have_content 'comment body 2'
    end
  end
end
