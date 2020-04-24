require "spec_helper"

describe Authentication do
  let(:authentication) { create :authentication }

  describe "validations" do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :uid }
    it { is_expected.to validate_presence_of :provider }
    it { is_expected.to validate_inclusion_of(:provider).in_array(["github", "google_oauth2"]) }
    it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:user_id) }
  end
end
