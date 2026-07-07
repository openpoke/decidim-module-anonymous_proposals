# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Method overrides to avoid errors when current_user is not present
    module PermissionsOverrides
      extend ActiveSupport::Concern

      def can_create_proposal?
        toggle_allow([authorized?(:create), allow_anonymous_proposals?].any? && current_settings&.creation_enabled?)
      end

      private

      def allow_anonymous_proposals?
        component_settings.anonymous_proposals_enabled?
      end
    end
  end
end
