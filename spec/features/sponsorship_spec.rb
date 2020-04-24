require "spec_helper"

describe "sponsoring an applicant" do
  let(:mature_member) { create(:mature_member) }
  let(:member) { create(:member) }
  let(:application) { create(:application) }

  describe "someone that has been a member for at least 2 weeks" do
    before do
      page.set_rack_session(user_id: mature_member.id)
    end

    it "allows a mature member to sponsor an application" do
      visit members_application_path(application)
      check "is_sponsor"
      expect { click_button "Submit" }.to change(Sponsorship, :count).from(0).to(1)
    end

    it "allows a mature member to sponsor an application" do
      visit members_application_path(application)
      check "is_sponsor"
      expect { click_button "Submit" }.to change(Sponsorship, :count).from(0).to(1)
    end

    it "allows a mature member to remove their sponsorship of an application" do
      visit members_application_path(application)
      check "is_sponsor"
      expect { click_button "Submit" }.to change(Sponsorship, :count).from(0).to(1)
      uncheck "is_sponsor"
      expect { click_button "Submit" }.to change(Sponsorship, :count).from(1).to(0)
    end
  end

  describe "someone that has been a member for less than 2 weeks" do
    before do
      page.set_rack_session(user_id: member.id)
    end

    it "cant see sponsorship checkbox" do
      visit members_application_path(application)
      expect(page).to have_text("You'll be able to sponsor applicants once you've been a member for 2 weeks!")
      expect(page).not_to have_css(".is_sponsor")
    end
  end
end
