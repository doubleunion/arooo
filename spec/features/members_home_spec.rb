require "spec_helper"

describe "Members home" do
  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a key member" do
    let(:member) { create :key_member }

    it "if they have no door code, tells them to email membership@" do
      visit members_root_path
      expect(page).to have_content "don't seem to have a door code"
      expect(page).to have_content "membership@doubleunion.com"
    end

    it "if they have a door code, it is shown" do
      door_code = create(:door_code, user: member)
      visit members_root_path
      expect(page).to have_content "Your door code"
      expect(page).to have_content door_code.code
    end

    it "shows if the door code is disabled" do
      door_code = create(:door_code, user: member, enabled: false)
      visit members_root_path
      expect(page).to have_content "#{door_code.code} (disabled)"
     end
  end

  context "when logged in as a non-key-member" do
    let(:member) { create :member }

    it "does not show content about the door code" do
      visit members_root_path
      expect(page).to_not have_content "door code"
    end
  end
end
