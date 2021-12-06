require "spec_helper"

describe DoorCode do
  subject { create(:door_code) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  end

  describe ".make_random_code" do
    it "returns a string" do
      expect(DoorCode.make_random_code()).to be_a String
    end

    it "returns a string of the requested length" do
      expect(DoorCode.make_random_code(digits: 16).length).to eq(16)
    end
  end

  describe "#status" do
    it "defaults to not_in_lock" do
      new_door_code = DoorCode.create!(user: create(:user), code: "12345")
      expect(new_door_code.not_in_lock?).to be true
    end
  end

  describe "#unassign" do
    it "removes the association to a user" do
      door_code = create(:door_code, :assigned)
      expect { door_code.unassign }.to change { door_code.user }.to(nil)
    end

    it "updates the door code status" do
      door_code = create(:door_code, :assigned, status: :in_lock)
      expect { door_code.unassign }.to change { door_code.status }.to(:formerly_assigned_in_lock.to_s)

      door_code = create(:door_code, :assigned, status: :not_in_lock)
      expect { door_code.unassign }.to change { door_code.status }.to(:formerly_assigned_not_in_lock.to_s)
    end
  end
end
