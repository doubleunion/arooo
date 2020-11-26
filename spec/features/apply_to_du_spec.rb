require "spec_helper"

describe "applying to double union" do
  let(:cool_cat) { create(:user) }
  let(:application_state) { cool_cat.application.state }

  before do
    cool_cat.update_attribute(:state, "applicant")
    page.set_rack_session(user_id: cool_cat.id)
  end

  it "allows the user to submit an application" do
    visit new_application_path

    fill_in "Twitter username", with: "@beepboopbeep"
    fill_in "Pronouns", with: "They/Them"
    fill_in "user_profile_attributes_attendance", with: "I went to the cool thing"
    check "user_application_attributes_agreement_terms"
    check "user_application_attributes_agreement_policies"
    check "user_application_attributes_agreement_female"

    expect {
      click_on "Submit application"
    }.to change { cool_cat.application.reload.state }.from("started").to("submitted")

    expect(page).to have_content "Application submitted!"
    expect(find_field("Pronouns").value).to eq "They/Them"
    expect(find_field("Twitter username").value).to eq "@beepboopbeep"
    expect(find_field("user_profile_attributes_attendance").value).to eq "I went to the cool thing"
  end

  it "allows the user to save their application without submitting it" do
    visit new_application_path
    expect(page).to have_content "We're glad you're interested"

    fill_in "Twitter username", with: "@beepboopbeep"
    fill_in "user_profile_attributes_attendance", with: "I went to the cool thing"

    first(:button, "Save without submitting").click

    expect(cool_cat.application.state).to eq("started")
    expect(page).to have_content "Application saved"
    expect { Application.count }.to change { Application.count }.by(0)
  end

  it "allows the user to update their application" do
    visit new_application_path
    expect(page).to have_content "We're glad you're interested"

    fill_in "Pronouns", with: "They/Them"
    fill_in "Twitter username", with: "@beepboopbeep"
    check "user_application_attributes_agreement_terms"
    check "user_application_attributes_agreement_policies"
    check "user_application_attributes_agreement_female"

    click_on "Submit application"

    fill_in "Pronouns", with: "Ze/Zir"
    fill_in "Twitter username", with: "@new_and_better_handle"

    first(:button, "Update application").click

    expect(find_field("Pronouns").value).to eq "Ze/Zir"
    expect(find_field("Twitter username").value).to eq "@new_and_better_handle"
  end
end
