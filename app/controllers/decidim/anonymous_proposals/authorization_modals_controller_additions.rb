# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    module AuthorizationModalsControllerAdditions
      extend ActiveSupport::Concern

      included do
        helper_method :allow_anonymous_proposals?

        prepend_before_action :set_ephemeral_user, only: [:show] # rubocop:disable Rails/LexicallyScopedActionFilter
      end

      private

      def set_ephemeral_user
        return unless allow_anonymous_proposals?

        create_ephemeral_user
      end

      def current_onboarding_data
        {
          "component" => current_component.to_gid,
          "model" => resource&.to_gid
        }
      end

      def allow_anonymous_proposals?
        current_component.settings&.anonymous_proposals_enabled?
      end
    end
  end
end
