require "spec_helper"

describe "Members home" do
  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a key member with a door code" do
    let(:member) { create :key_member }

    before do
      create :door_code, code: "123456", user: member
    end

    it "shows their door code" do
      visit members_root_path
      expect(page).to have_content "Your door code is 123456*"
    end
  end

  context "when logged in as a non-key-member" do
    let(:member) { create :member }

    it "shows a button to become a key member" do
      visit members_root_path
      expect(page).to have_link "Become a key member"
    end

    it "does not show a door code" do
      visit members_root_path
      expect(page).to_not have_content "Your door code is"
    end
  end
end
