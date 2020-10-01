require "spec_helper"

describe Sponsorship do
  describe "validations" do
    it { should belong_to(:user) }
    it { should belong_to(:application) }
  end

  describe "relationships" do
    let(:user) { create :user }
    let(:application) { create :application, user: user }
    let(:sponsorship) { create :sponsorship, user: user, application: application }

    it "both directions work" do
      expect(sponsorship.application.user).to eq(sponsorship.user)
      expect(application.sponsorships[0].user).to eq(application.user)
    end
  end
end
