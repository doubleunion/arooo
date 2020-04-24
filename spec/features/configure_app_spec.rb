require "spec_helper"

describe "opening and closing applications" do
  let(:admin) { create(:admin) }
  let(:applicant) { create(:applicant) }

  context "when applications are closed" do
    before do
      page.set_rack_session(user_id: admin.id)
      visit admin_configurable_path
      uncheck "Accepting applications"
      click_button "Save"
    end

    context "as an applicant" do
      before do
        page.set_rack_session(user_id: applicant.id)
        visit edit_application_path(applicant.application)
      end

      it "should redirect to the membership page with a flash message" do
        expect(page).to have_content "Double Union isn't currently accepting applications."
      end

      it "should not show me my application" do
        expect(page).not_to have_content "Hi, #{applicant.username}! We're glad you're"
      end
    end
  end

  context "when applications are open" do
    context "as an applicant" do
      before do
        page.set_rack_session(user_id: applicant.id)
        visit edit_application_path(applicant.application)
      end

      it "should show me my application" do
        expect(page).to have_content "Hello! We're glad you're interested in becoming a member of Double Union."
      end
    end
  end
end
