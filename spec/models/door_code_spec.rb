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
end
