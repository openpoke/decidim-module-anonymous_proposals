# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    class AnonymousProposalBroker
      def initialize(settings)
        @settings = settings
      end

      def allowed?
        return false unless correct_settings?

        settings.anonymous_proposals_enabled? && allowed_timeframe?
      end

      private

      attr_reader :settings

      def allowed_timeframe?
        return true unless timeframe_enabled?

        within_timeframe?
      end

      def correct_settings?
        [
          settings.respond_to?(:anonymous_proposals_enabled?),
          settings.respond_to?(:anonymous_proposal_start_time),
          settings.respond_to?(:anonymous_proposal_end_time)
        ].all?
      end

      def within_timeframe?
        [
          settings.anonymous_proposal_start_time.to_i <= Time.current.hour,
          settings.anonymous_proposal_end_time.to_i > Time.current.hour
        ].all?
      end

      def timeframe_enabled?
        [settings.anonymous_proposal_start_time.present?, settings.anonymous_proposal_end_time.present?].all?
      end
    end
  end
end
