require "spec_helper"

describe Authentication do
  let(:authentication) { create :authentication }

  describe "validations" do
    it { should validate_presence_of :user }
    it { should validate_presence_of :uid }
    it { should validate_presence_of :provider }
    it { should validate_inclusion_of(:provider).in_array(["github"])}
    it { should validate_uniqueness_of(:uid).scoped_to(:user_id)}
  end
end
