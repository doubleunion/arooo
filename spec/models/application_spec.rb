require 'spec_helper'

describe Application do
  it 'should be invalid without user id' do
    Application.new.tap(&:valid?).should have_at_least(1).errors_on(:user_id)
  end

  it 'should be valid with user id' do
    application = Application.new
    application.user = User.make!
    application.valid?.should be_true
  end
end
