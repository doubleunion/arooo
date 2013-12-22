require 'spec_helper'

describe 'sponsoring an applicant' do
  let(:member) { create(:member) }
  let(:application) { create(:application) }

  before do
    page.set_rack_session(:user_id => member.id)
  end

  it 'allows a member to sponsor an application' do
    visit admin_application_path(application)
    check "is_sponsor"
    expect { click_button "Sponsor" }.to change(Sponsorship, :count).from(0).to(1)
  end

  it 'allows a member to remove their sponsorship of an application' do
    visit admin_application_path(application)
    check "is_sponsor"
    expect { click_button "Sponsor" }.to change(Sponsorship, :count).from(0).to(1)
    uncheck "is_sponsor"
    expect { click_button "Sponsor" }.to change(Sponsorship, :count).from(1).to(0)
  end
end
