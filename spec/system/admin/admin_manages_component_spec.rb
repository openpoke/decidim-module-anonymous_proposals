# frozen_string_literal: true

require "spec_helper"

describe "Admin manages component publication" do # rubocop:disable RSpec/DescribeClass
  include_context "when managing a component as an admin" do
    let!(:component) { create(:proposal_component, participatory_space:) }
    let(:title) { translated(current_component.name) }

    context "when creating a component", :versioning do
      it "can create a proposals component with anonymous proposals enabled" do
        expect(participatory_space.organization.available_authorizations).not_to include("anonymous_proposals_handler")

        expect(component.reload.organization.available_authorizations).not_to include("anonymous_proposals_handler")
        visit decidim_admin_participatory_processes.components_path(component.participatory_space)
        within ".sidebar-menu" do
          click_on "Components"
        end

        click_on "Add component"
        within "#add-component-dropdown" do
          click_on "Proposals"
        end

        step_settings = find_by_id("step_settings")
        page.scroll_to step_settings

        expect(page).to have_content("Allow anonymous users to create proposals")
        check "Allow anonymous users to create proposals"

        click_on "Add component"

        expect(page).to have_admin_callout("Component created successfully. You can add a content block for this component in the home of the space.")

        # NOTE: We only assert the organization-level authorization handler here (component settings are not directly asserted in this flow).
        expect(participatory_space.reload.organization.available_authorizations).to include("anonymous_proposals_handler")
      end
    end

    context "when updating a component" do
      it "can set the proposal to accept anonymous proposals" do
        expect(component.reload.organization.available_authorizations).not_to include("anonymous_proposals_handler")
        expect(component.permissions).to be_nil

        visit decidim_admin_participatory_processes.components_path(component.participatory_space)
        within ".sidebar-menu" do
          click_on "Components"
        end

        within "tr", text: title do
          find("button[data-controller='dropdown']").click
          click_on "Configure"
        end

        step_settings = find_by_id("step_settings")
        page.scroll_to step_settings

        expect(page).to have_content("Allow anonymous users to create proposals")
        check "Allow anonymous users to create proposals"

        click_on "Update"

        expect(page).to have_admin_callout("The component was updated successfully.")

        expect(component.reload.settings).to be_anonymous_proposals_enabled
        expect(component.reload.organization.available_authorizations).to include("anonymous_proposals_handler")
        expect(component.permissions.dig("withdraw", "authorization_handlers")).to include({ "anonymous_proposals_handler" => {} })

        within "tr", text: title do
          find("button[data-controller='dropdown']").click
          click_on "Configure"
        end

        step_settings = find_by_id("step_settings")
        page.scroll_to step_settings

        expect(page).to have_content("Allow anonymous users to create proposals")
        uncheck "Allow anonymous users to create proposals"

        click_on "Update"

        expect(page).to have_admin_callout("The component was updated successfully.")

        expect(component.reload.settings).not_to be_anonymous_proposals_enabled
        expect(component.reload.organization.available_authorizations).to include("anonymous_proposals_handler")
        expect(component.reload.permissions).to be_empty
      end

      it "can set the proposal to accept anonymous proposals within a timeframe" do
        expect(component.reload.organization.available_authorizations).not_to include("anonymous_proposals_handler")
        expect(component.permissions).to be_nil

        visit decidim_admin_participatory_processes.components_path(component.participatory_space)
        within ".sidebar-menu" do
          click_on "Components"
        end

        within "tr", text: title do
          find("button[data-controller='dropdown']").click
          click_on "Configure"
        end

        step_settings = find_by_id("step_settings")
        page.scroll_to step_settings

        expect(page).to have_content("Allow anonymous users to create proposals")
        check "Allow anonymous users to create proposals"
        select "01:00", from: :component_settings_anonymous_proposal_start_time
        select "11:00", from: :component_settings_anonymous_proposal_end_time

        click_on "Update"

        expect(component.reload.settings).to be_anonymous_proposals_enabled
        expect(component.reload.settings.anonymous_proposal_start_time).to eq "1"
        expect(component.reload.settings.anonymous_proposal_end_time).to eq "11"
        expect(component.reload.organization.available_authorizations).to include("anonymous_proposals_handler")
        expect(component.permissions.dig("withdraw", "authorization_handlers")).to include({ "anonymous_proposals_handler" => {} })

        within "tr", text: title do
          find("button[data-controller='dropdown']").click
          click_on "Configure"
        end

        step_settings = find_by_id("step_settings")
        page.scroll_to step_settings

        expect(page).to have_content("Allow anonymous users to create proposals")
        uncheck "Allow anonymous users to create proposals"
        select "", from: :component_settings_anonymous_proposal_start_time
        select "", from: :component_settings_anonymous_proposal_end_time

        click_on "Update"

        expect(page).to have_admin_callout("The component was updated successfully.")

        expect(component.reload.settings).not_to be_anonymous_proposals_enabled
        expect(component.reload.settings.anonymous_proposal_start_time).to eq("")
        expect(component.reload.settings.anonymous_proposal_end_time).to eq("")
        expect(component.reload.organization.available_authorizations).to include("anonymous_proposals_handler")
        expect(component.reload.permissions).to be_empty
      end
    end
  end
end
