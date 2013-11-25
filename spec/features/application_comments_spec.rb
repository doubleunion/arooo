require 'spec_helper'

describe "commenting on an application" do
  let(:member) { create(:user) }
  let(:application) { create(:application) }
  let(:applicant) { application.user }

  before do
    member.update_attribute('state', 'member')
    applicant.update_attribute('state', 'applicant')
    page.set_rack_session(:user_id => member.id)
    application.update_attribute('state', 'submitted')
  end

  it "allows the member to comment on the application" do
    visit admin_application_path(application.id)

    fill_in "comment_comment", with: "I am a cool comment"
    click_button "Add Comment"

    expect(page).to have_content("by #{member.name}")
    expect(page).to have_content("I am a cool comment")
  end
end
