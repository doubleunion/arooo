require "spec_helper"

describe DoorCode do
  describe "validations" do
    it { is_expected.to validate_presence_of :code }
  end
end
