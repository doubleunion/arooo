require "spec_helper"

describe "diplaying age on application" do

  before do
    @submitted_application = create(:user, state: :applicant).application
    @submitted_application.update_attribute(:state, "submitted")
    @submitted_application.update_attribute(:submitted_at, 1.week.ago)
  end

  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a voting member" do
    let(:member) { create(:voting_member) }

    it "displays the correct application age" do
      visit members_applications_path
      expect(page).to have_content "Age"
      #This spec controls the age of the application so the age can be hardcoded in
      expect(page).to have_content "7 days"
    end
  end
end
