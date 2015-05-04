require "spec_helper"

describe "becoming a key member" do

  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a member" do
    let(:member) { create :member }

    it "allows a member to become a key member" do
      visit edit_members_user_status_path(member)
      check "agreements[kick_out]"
      check "agreements[lock_up]"
      check "agreements[take_action]"
      click_button "Submit"
      expect(page).to have_content "Yay, you're now a key member!"
    end
  end
end

describe "updating membership status" do
  before { page.set_rack_session(user_id: admin.id) }

  context "when logged in as an admin" do
    let(:admin) { create :admin }

    context "with a member" do
      let!(:member) { create :member }

      it "allows a member to become a key member" do
        visit admin_memberships_path
        click_button "Make Key member"

        expect(page).to have_content "#{member.name} is now a key member."
        within(".user-#{member.id}") do
          expect(page).to have_content "key member"
        end
      end

      it "allows membership to be cancelled" do
        visit admin_memberships_path
        within(".user-#{member.id}") do
          click_button "Revoke DU Membership"
        end

        expect(page).to have_content "#{member.name} is now a former member."
        expect(member.reload.state).to eq "former_member"
      end
    end

    context "with a key member" do
      let!(:member) { create :key_member }

      it "allows key membership to be cancelled" do
        visit admin_memberships_path
        click_button "Revoke Key membership"

        expect(page).to have_content "#{member.name} is now a member."
        within(".user-#{member.id}") do
          expect(page).to have_content "member"
          expect(page).not_to have_content "key member"
        end
      end

      it "allows membership to be cancelled" do
        visit admin_memberships_path
        within(".user-#{member.id}") do
          click_button "Revoke DU Membership"
        end

        expect(page).to have_content "#{member.name} is now a former member."
        expect(member.reload.state).to eq "former_member"
      end
    end

    context "with a voting member" do
      let!(:member) { create :voting_member }

      it "allows key membership to be cancelled" do
        visit admin_memberships_path
        within(".user-#{member.id}") do
          click_button "Revoke Voting membership"
        end

        expect(page).to have_content "#{member.name} is now a key member."
        within(".user-#{member.id}") do
          expect(page).to have_content "key member"
          expect(page).not_to have_content "voting member"
        end
      end

      it "allows membership to be cancelled" do
        visit admin_memberships_path
        within(".user-#{member.id}") do
          click_button "Revoke DU Membership"
        end

        expect(page).to have_content "#{member.name} is now a former member."
        expect(member.reload.state).to eq "former_member"
      end
    end
  end
end
