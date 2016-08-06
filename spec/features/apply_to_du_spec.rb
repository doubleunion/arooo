require 'spec_helper'

describe "applying to double union" do
  let(:cool_lady) { create(:user) }
  let(:application_state) { cool_lady.application.state }

  before do
    cool_lady.update_attribute(:state, "applicant")
    page.set_rack_session(user_id: cool_lady.id)
  end

  it "allows the user to submit an application" do
    visit new_application_path

    fill_in "Twitter username", with: "@beepboopbeep"
    fill_in "Blog URL", with: "http://blog.awesome.com"
    fill_in "Pronoun", with: "They/Them"
    check "user_application_attributes_agreement_terms"
    check "user_application_attributes_agreement_policies"
    check "user_application_attributes_agreement_female"

    expect {
      click_on "Submit application"
    }.to change { cool_lady.application.reload.state }.from("started").to("submitted")

    expect(page).to have_content "Application submitted!"
    expect(find_field('Twitter username').value).to eq "@beepboopbeep"
  end

  it "allows the user to save her application without submitting it" do
    visit new_application_path
    expect(page).to have_content "We're glad you're interested"

    fill_in "Twitter username", with: "@beepboopbeep"
    fill_in "Tell us a little about yourself!", with: "I am definitely not a cat!"

    first(:button, "Save without submitting").click

    expect(cool_lady.application.state).to eq("started")
    expect(page).to have_content "Application saved"
    expect {Application.count}.to change{Application.count}.by(0)
  end

  it "allows the user to update her application" do
    visit new_application_path
    expect(page).to have_content "We're glad you're interested"

    fill_in "Twitter username", with: "@beepboopbeep"
    fill_in "Blog URL", with: "http://blog.awesome.com"
    check "user_application_attributes_agreement_terms"
    check "user_application_attributes_agreement_policies"
    check "user_application_attributes_agreement_female"

    click_on "Submit application"

    fill_in "Twitter username", with: "@new_and_better_handle"

    first(:button, "Update application").click

    expect(find_field('Twitter username').value).to eq "@new_and_better_handle"
  end

end
