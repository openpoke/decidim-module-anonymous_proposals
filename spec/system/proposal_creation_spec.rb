# frozen_string_literal: true

require "spec_helper"

describe "Create_proposal" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest:,
           participatory_space:,
           organization:,
           settings: {
             anonymous_proposals_enabled: true
           })
  end

  context "when visiting proposal component with anonymous proposals enabled" do
    it "shows button to create proposal" do
      visit_component

      expect(page).to have_content("New proposal")
      expect(page).to have_content("If you publish your proposal as registered user")
    end
  end

  context "when visiting proposal component without anonymous proposals enabled" do
    before do
      settings = {
        anonymous_proposals_enabled: false
      }
      component.update!(settings:)

      visit_component
    end

    it "does not show announcements" do
      expect(page).to have_no_content("If you publish your proposal as registered user")
    end

    context "when creating a new proposal" do
      context "when the user is not logged_in" do
        before do
          visit_component
          click_on "New proposal"
        end

        it "gets redirected to register/login" do
          expect(page).to have_content("Create an account")
        end
      end
    end
  end

  context "when creating a new proposal" do
    context "when the user is not logged in" do
      before do
        settings = {
          anonymous_proposals_enabled: true
        }
        component.update!(settings:)

        create(:user, :confirmed, organization:, extended_data: { anonymous: true }, email: "anonymous+#{organization.id}@example.org", nickname: "anonymous_#{organization.id}")

        visit_component
        click_on "New proposal"
      end

      it "shows the announcement" do
        expect(page).to have_content("Do you want other participants to follow you and comment on your proposal?")
      end
    end
  end
end
