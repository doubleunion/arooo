require "spec_helper"

describe "becoming a key member" do
  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a member" do
    let(:member) { create :member }

    it "allows a member to become a key member" do
      visit edit_members_user_key_members_path(member)
      check "agreements[kick_out]"
      check "agreements[lock_up]"
      check "agreements[take_action]"
      check "agreements[attended_events]"
      click_button "Submit"
      expect(page).to have_content "Yay, you're now a key member!"
    end
  end
end

describe "submitting the voting member agreement" do
  let(:member) { create(:member) }

  before { page.set_rack_session(user_id: member.id) }

  it "allows a member to submit the voting member agreement" do
    visit members_root_path
    click_link "Become a voting member"
    expect(page).to have_content "Voting Member Agreement"
    check "I have read and agree to uphold the confidentiality policy."
    check "I have read and agree to uphold the voting members policy."
    check "I agree to vote on applications according to the criteria laid out in the voting members policy."
    check "I have attended a voting member training"
    check "I am able to dedicate 30-60 minutes per week to voting"
    check "During the course of voting on applications, I am willing to discuss difficult topics in a respectful and thoughtful way."
    click_on "Submit"
    expect(page).to have_content "Thank you for volunteering to serve as a voting member! A membership coordinator will be in touch soon."
  end
end

describe "marking members as on scholarship" do
  before { page.set_rack_session(user_id: admin.id) }

  context "when logged in as an admin" do
    let(:admin) { create :admin }

    context "with a member" do
      let!(:member) { create :member }

      it "allows members to be marked as on scholarship" do
        visit admin_memberships_path
        within(".user-#{member.id}") do
          click_button "Mark as on scholarship"
        end

        within(".user-#{member.id}") do
          expect(page).to have_content "Yes"
        end
      end

      context "with a scholarship member" do
        before { member.update_attributes(is_scholarship: true) }

        it "allows members to be marked as not on scholarship" do
          visit admin_memberships_path
          within(".user-#{member.id}") do
            click_button "Remove scholarship"
          end

          within(".user-#{member.id}") do
            expect(page).to have_content "No"
          end
        end
      end
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

      context "who has agreed to the voting member agreement" do
        before { member.update!(voting_policy_agreement: true) }

        it "allows a member to become a voting member" do
          visit admin_memberships_path
          click_button "Make Voting member"

          expect(page).to have_content "#{member.name} is now a voting member."
          within(".user-#{member.id}") do
            expect(page).to have_content "voting member"
          end
        end
      end

      context "who has not agreed to the voting member agreement" do
        it "does not show the make voting member button" do
          visit admin_memberships_path
          click_button "Make Key member"

          expect(page).not_to have_content "Make voting member"
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

      it "allows voting membership to be cancelled" do
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
