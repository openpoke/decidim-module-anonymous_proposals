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
        within_bounds?(
          Time.local(Date.current.year, Date.current.month, Date.current.day, settings.anonymous_proposal_start_time.to_i, 0).in_time_zone,
          Time.local(Date.current.year, Date.current.month, Date.current.day, settings.anonymous_proposal_end_time.to_i, 0).in_time_zone,
          Time.current
        )
      end

      def within_bounds?(start_hour, end_hour, current_hour)
        if start_hour <= end_hour
          start_hour <= current_hour && current_hour < end_hour
        else
          current_hour >= start_hour || current_hour < end_hour
        end
      end

      def timeframe_enabled?
        [settings.anonymous_proposal_start_time.present?, settings.anonymous_proposal_end_time.present?].all?
      end
    end
  end
end
