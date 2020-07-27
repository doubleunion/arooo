require "spec_helper"

describe DoorCode do
  subject { create(:door_code) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_uniqueness_of(:user).case_insensitive }
  end

  describe "#enabled" do
    it "is false by default" do
      new_door_code = DoorCode.create!(user: create(:user), code: "12345")
      expect(new_door_code.enabled).to be false
    end
  end

  describe ".enabled" do
    let!(:disabled_code) { create(:door_code, enabled: false)}
    let!(:enabled_code) { create(:door_code, enabled: true)}

    it "includes enabled doorcodes" do
      expect(DoorCode.enabled).to include(enabled_code)
    end

    it "does not include disabled doorcodes" do
      expect(DoorCode.enabled).to_not include(disabled_code)
    end
  end
end
