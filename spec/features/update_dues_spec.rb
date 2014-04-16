require 'spec_helper'

describe "updating dues" do
  let(:member) { create(:member) }

  before do
    page.set_rack_session(user_id: member.id)
  end

  it "allows members to update their dues pledge" do
    visit members_user_dues_path(member)

    fill_in "user_dues_pledge", with: "25"
    click_button "Update"

    expect(member.reload.dues_pledge).to eq(25)
    expect(page).to have_content("Manage Your Double Union Dues")
  end
end
