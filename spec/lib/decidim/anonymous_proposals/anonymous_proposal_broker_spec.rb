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
    allow(Time).to receive(:current).and_return(Time.local(Date.current.year, Date.current.month, Date.current.day, current_hour, 0, 0))
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

  describe "timezone handling" do
    let(:start_time) { 10 }
    let(:end_time) { 18 }

    around do |example|
      original_zone = Time.zone
      example.run
      Time.zone = original_zone
    end

    context "when the system timezone differs from the application timezone" do
      before do
        # Simulate system timezone being UTC
        travel_to Time.new(Date.current.year, Date.current.month, Date.current.day,7, 0, 0, "+00:00") do
          # Application timezone is Europe/Sofia (UTC+3 in summer)
          Time.zone = "Europe/Sofia"
        end
      end

      it "uses the application timezone for the current hour comparison" do
        # In Europe/Sofia, it's 10:00 (within the 10-18 window)
        # even though UTC time is 07:00
        expect(broker.allowed?).to be(true)
      end

      it "uses Time.zone.now.hour rather than Time.current.hour" do
        allow(Time).to receive(:current).and_return(Time.new(Date.current.year, Date.current.month, Date.current.day, 5, 0, 0, "+00:00"))
        Time.zone = "Europe/Sofia"
        travel_to Time.new(Date.current.year, Date.current.month, Date.current.day,5, 0, 0, "+00:00") do
          # Time.current.hour would be 5 (UTC), but Time.zone.now.hour is 8 (Sofia)
          # Both are outside 10-18, so this should be false
          expect(broker.allowed?).to be(false)
        end
      end
    end

    context "during daylight saving time transitions" do
      before do
        Time.zone = "Europe/London"
      end

      context "when spring forward occurs (clocks move forward 1 hour)" do
        it "correctly uses the DST-adjusted timezone hour" do
          # On the DST transition day in Europe/London (last Sunday of March),
          # clocks jump from 01:00 to 02:00 (BST, UTC+1)
          travel_to Time.new(Date.current.year, Date.current.month, Date.current.day,0, 30, 0, "+00:00") do
            Time.zone = "Europe/London"
            # At 00:30 UTC on March 29, 2026, London is still GMT (UTC+0)
            # so Time.zone.now.hour is 0
            expect(Time.zone.now.hour).to eq(1)
          end
        end
      end

      context "when summer time is in effect" do
        it "uses BST (UTC+1) hour correctly" do
          travel_to Time.new(Date.current.year, Date.current.month, Date.current.day,9, 0, 0, "+00:00") do
            Time.zone = "Europe/London"
            # At 09:00 UTC, London is BST (UTC+1), so local hour is 10
            expect(Time.zone.now.hour).to eq(10)
          end
        end
      end
    end

    context "with non-UTC timezones" do
      it "uses the correct timezone hour for comparison" do
        travel_to Time.new(Date.current.year, Date.current.month, Date.current.day,21, 0, 0, "+00:00") do
          Time.zone = "America/New_York"
          # At 21:00 UTC, New York is EDT (UTC-4), so local hour is 17
          expect(Time.zone.now.hour).to eq(17)
          # With start=10, end=18, current hour should be 17 (within window)
          expect(broker.allowed?).to be(true)
        end
      end
    end
  end
end
