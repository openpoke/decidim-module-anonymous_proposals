# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::AnonymousProposals::AnonymousProposalBroker do
  subject(:broker) { described_class.new(settings) }

  let(:anonymous_proposals_enabled) { true }
  let(:start_time) { nil }
  let(:end_time) { nil }
  let(:current_hour) { 12 }

  let(:settings) do
    double(
      anonymous_proposals_enabled?: anonymous_proposals_enabled,
      anonymous_proposal_start_time: start_time,
      anonymous_proposal_end_time: end_time
    )
  end

  before do
    allow(Time).to receive(:current).and_return(Time.new(2026, 7, 31, current_hour, 0, 0, 0))
  end

  describe "#allowed?" do
    context "when the settings do not provide the required methods" do
      let(:settings) { double(anonymous_proposals_enabled?: true) }

      it "returns false" do
        expect(broker.allowed?).to be(false)
      end
    end

    context "when anonymous proposals are disabled" do
      let(:anonymous_proposals_enabled) { false }
      let(:start_time) { 9 }
      let(:end_time) { 17 }
      let(:current_hour) { 12 }

      it "returns false" do
        expect(broker.allowed?).to be(false)
      end
    end

    context "when no timeframe is configured" do
      let(:current_hour) { 12 }

      it "returns true" do
        expect(broker.allowed?).to be(true)
      end
    end

    context "when only the start hour is configured" do
      let(:start_time) { 9 }

      it "returns true regardless of the current hour" do
        expect(broker.allowed?).to be(true)
      end
    end

    context "when only the end hour is configured" do
      let(:end_time) { 17 }

      it "returns true regardless of the current hour" do
        expect(broker.allowed?).to be(true)
      end
    end

    context "when the start hour is before the end hour" do
      let(:start_time) { 9 }
      let(:end_time) { 17 }

      context "when the current hour is inside the window" do
        let(:current_hour) { 12 }

        it "returns true" do
          expect(broker.allowed?).to be(true)
        end
      end

      context "when the current hour is outside the window" do
        let(:current_hour) { 20 }

        it "returns false" do
          expect(broker.allowed?).to be(false)
        end
      end
    end

    context "when the start hour is after the end hour (crosses midnight)" do
      let(:start_time) { 22 }
      let(:end_time) { 6 }

      context "when the current hour is before midnight" do
        let(:current_hour) { 23 }

        it "returns true" do
          expect(broker.allowed?).to be(true)
        end
      end

      context "when the current hour is after midnight" do
        let(:current_hour) { 5 }

        it "returns true" do
          expect(broker.allowed?).to be(true)
        end
      end

      context "when the current hour is outside the window" do
        let(:current_hour) { 12 }

        it "returns false" do
          expect(broker.allowed?).to be(false)
        end
      end
    end
  end

  describe "#within_timeframe?" do
    context "when the start hour is before the end hour" do
      let(:start_time) { 9 }
      let(:end_time) { 17 }

      context "when the current hour is inside the window" do
        let(:current_hour) { 12 }

        it "returns true" do
          expect(broker.send(:within_timeframe?)).to be(true)
        end
      end

      context "when the current hour is at the end hour" do
        let(:current_hour) { 17 }

        it "returns false" do
          expect(broker.send(:within_timeframe?)).to be(false)
        end
      end

      context "when the window ends at end of day" do
        let(:end_time) { 24 }

        context "when the current hour is the last hour of the day" do
          let(:current_hour) { 23 }

          it "returns true" do
            expect(broker.send(:within_timeframe?)).to be(true)
          end
        end

        context "when the current hour is before the start hour" do
          let(:current_hour) { 8 }

          it "returns false" do
            expect(broker.send(:within_timeframe?)).to be(false)
          end
        end
      end
    end

    context "when the start hour is after the end hour (crosses midnight)" do
      let(:start_time) { 22 }
      let(:end_time) { 6 }

      context "when the current hour is before midnight" do
        let(:current_hour) { 23 }

        it "returns true" do
          expect(broker.send(:within_timeframe?)).to be(true)
        end
      end

      context "when the current hour is after midnight" do
        let(:current_hour) { 5 }

        it "returns true" do
          expect(broker.send(:within_timeframe?)).to be(true)
        end
      end

      context "when the current hour is outside the window" do
        let(:current_hour) { 12 }

        it "returns false" do
          expect(broker.send(:within_timeframe?)).to be(false)
        end
      end
    end
  end

  describe "#correct_settings?" do
    context "when the settings provide all the required methods" do
      it "returns true" do
        expect(broker.send(:correct_settings?)).to be(true)
      end
    end

    context "when a required method is missing" do
      let(:settings) { double(anonymous_proposals_enabled?: true) }

      it "returns false" do
        expect(broker.send(:correct_settings?)).to be(false)
      end
    end
  end
end
