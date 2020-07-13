require "spec_helper"

describe ApiController do
  describe "#public_members" do
    let!(:public_member) { create :member }
    let!(:another_public_member) { create :member }
    let(:member_json) {
      {
        name: public_member.name,
        state: public_member.display_state,
        gravatar_url: public_member.gravatar_url,
        profile: {website: public_member.profile.website}
      }
    }
    let(:another_member_json) {
      {
        name: another_public_member.name,
        state: another_public_member.display_state,
        gravatar_url: another_public_member.gravatar_url,
        profile: {website: another_public_member.profile.website}
      }
    }

    before do
      public_member.profile.update_column(:show_name_on_site, true)
      another_public_member.profile.update_column(:show_name_on_site, true)
    end

    subject { get :public_members, format: :json }

    it "succeeds" do
      subject
      expect(response).to be_successful
    end

    it "returns a list of public members" do
      subject
      expect(response.body).to include(member_json.to_json, another_member_json.to_json)
    end

    context "with an unlisted member" do
      let(:private_member) { create :member } # members are private by default

      it "doesn't include an unlisted member" do
        get :public_members, format: :json
        expect(response.body).not_to include private_member.name
      end
    end
  end

  describe "#configurations" do
    subject { get :configurations, format: :json }

    let(:config_json) { {configurations: {accepting_applications: true}} }

    it "returns the configurations" do
      subject
      expect(response).to be_successful
      expect(response.body).to eq config_json.to_json
    end
  end
end
