require "spec_helper"

describe "member viewing comments" do
  before do
    Timecop.freeze(now)
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a member" do
    let(:now) { Date.new(2019, 1, 1) }
    let(:member) { create :member }
    let!(:comment_1) { create :comment, body: "comment body 1", created_at: now - 3.days, application: app1 }
    let!(:comment_2) { create :comment, body: "comment body 2", created_at: now - 2.days, application: app1 }
    let!(:comment_3) { create :comment, body: "comment body 3", created_at: now - 2.days, application: app2 }
    let(:app1) { create(:application, state: "submitted") }
    let(:app2) { create(:application, state: "approved") }

    it "shows comments" do
      visit members_comments_path(member)
      expect(page).to have_content "Recent Comments"
      expect(page).to have_content "comment body 1"
      expect(page).to have_content "2018-12-29 00:00:00"
      expect(page).to have_content "comment body 2"
      expect(page).to have_content "2018-12-30 00:00:00"
      expect(page).not_to have_content "comment body 3"
    end
  end
end
