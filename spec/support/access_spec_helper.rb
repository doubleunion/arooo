shared_examples "deny non-members" do |folks|
  folks.each do |folk|
    it "should deny non-members" do
      login_as(folk)
      subject
      expect(response).to redirect_to :root
    end
  end
end

shared_examples "allow members" do |folks|
  folks.each do |folk|
    it "should allow members" do
      login_as(folk)
      subject
      expect(response).to be_successful
    end
  end
end
