require 'spec_helper'

describe Members::VotesController do
  include AuthHelper

  let(:application) { create(:application) }

  describe "POST create" do
    let(:params) { {
      vote: { application_id: application.id }, "vote_no" => "No"
    } }

    before do
      login_as(member)
    end

    subject { post :create, params }

    context "when logged in as a voting member" do
      let(:member) { create(:voting_member) }

      it "create the correct vote" do
        subject
        expect(Vote.last.application_id).to eq application.id
        expect(Vote.last.user_id).to eq member.id
      end

      describe "voting no" do
        it "stores the correct value" do
          subject
          expect(Vote.last.value).to be_false
        end
      end

      describe "voting yes" do
        let(:params) { {
          vote: { application_id: application.id }, "vote_yes" => "Yes"
        } }

        it "stores the correct value" do
          subject
          expect(Vote.last.value).to be_true
        end
      end
    end
  end
end
