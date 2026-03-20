require "spec_helper"

describe "Members home" do
  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a key member" do
    let(:member) { create :key_member }

    it "shows space access information" do
      visit members_root_path
      expect(page).to have_content "Please reach out to Admins below via Email or Slack to get your own door passcode, thanks!"
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
