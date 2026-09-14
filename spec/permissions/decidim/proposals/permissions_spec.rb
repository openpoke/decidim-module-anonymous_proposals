# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:user) { create(:user, organization: proposal_component.organization) }
  let(:context) do
    {
      current_component: proposal_component,
      current_settings:,
      component_settings:,
      coauthor:
    }
  end
  let(:coauthor) { nil }
  let(:proposal_component) { create(:proposal_component) }
  let(:component_settings) do
    double(
      vote_limit: 2,
      anonymous_proposals_enabled?: anonymous_proposals_enabled,
      anonymous_proposal_start_time:,
      anonymous_proposal_end_time:
    )
  end
  let(:current_settings) do
    double(settings.merge(extra_settings))
  end
  let(:settings) do
    {
      creation_enabled?: creation_enabled
    }
  end
  let(:anonymous_proposal_end_time) { nil }
  let(:anonymous_proposal_start_time) { nil }
  let(:anonymous_proposals_enabled) { false }
  let(:extra_settings) { {} }
  let(:action) { { scope: :public, action: :create, subject: :proposal } }
  let(:creation_enabled) { true }

  context "when creating a proposal" do
    context "and creation is disabled" do
      let(:creation_enabled) { false }

      it { is_expected.to be false }
    end

    context "and user is authorized" do
      it { is_expected.to be true }
    end
  end

  context "when accepting anonymous proposals" do
    let(:user) { create(:user, :ephemeral, organization: proposal_component.organization) }
    let(:anonymous_proposals_enabled) { true }

    context "and creation is disabled" do
      let(:creation_enabled) { false }

      it { is_expected.to be false }
    end

    context "and user sis set" do
      it { is_expected.to be true }
    end

    context "and time start is set, but end is not" do
      let(:anonymous_proposal_start_time) { "10" }

      it { is_expected.to be true }
    end

    context "and time end is set, but start is not" do
      let(:anonymous_proposal_end_time) { "00" }

      it { is_expected.to be true }
    end

    context "and start time and end time is set" do
      let(:anonymous_proposal_start_time) { "10" }
      let(:anonymous_proposal_end_time) { "12" }

      context "and within timeframe" do
        it { travel_to(Time.zone.now.beginning_of_day + 11.hours) { is_expected.to be true } }
      end

      context "and outside timeframe" do
        it "submits before" do
          travel_to(Time.zone.now.beginning_of_day + 9.hours + 59.minutes + 59.seconds) { expect(subject).to be false }
        end

        it "submits after" do
          travel_to(Time.zone.now.beginning_of_day + 12.hours + 1.second) { expect(subject).to be false }
        end
      end
    end
  end
end
