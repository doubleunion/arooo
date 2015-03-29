require "spec_helper"

describe "becoming a key member" do

  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a member" do
    let(:member) { create :member }

    it "allows a member to become a voting member" do
      visit edit_members_user_status_path(member)
      check "agreements[kick_out]"
      check "agreements[lock_up]"
      check "agreements[take_action]"
      click_button "Submit"
      expect(page).to have_content "Yay, you're now a key member!"
    end
  end
end
