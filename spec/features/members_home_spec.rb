require "spec_helper"

describe "Members home" do
  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a key member" do
    let(:member) { create :key_member }

    it "it allows them to unlock the door" do
      visit members_root_path
      expect(page).to have_content "Click the button below to unlock the door and access the space"
    end
  end

  context "when logged in as a non-key-member" do
    let(:member) { create :member }

    it "does not show content about unlocking the door" do
      visit members_root_path
      expect(page).to_not have_content "unlock the door"
    end
  end
end
