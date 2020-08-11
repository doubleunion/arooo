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

  describe ".new_for_user" do
    let(:member) { create(:member) }

    it "returns a persisted door code" do
      expect(DoorCode.new_for_user(member).persisted?).to eq(true)
    end

    it "is assigned to the given user" do
      expect(DoorCode.new_for_user(member).user).to eq(member)
    end

    it "has a 6-digit code" do
      expect(DoorCode.new_for_user(member).code.length).to eq(6)
    end
  end

  describe ".make_random_code" do
    it "returns a string" do
      expect(DoorCode.make_random_code()).to be_a String
    end

    it "returns a string of the requested length" do
      expect(DoorCode.make_random_code(digits: 16).length).to eq(16)
    end
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
