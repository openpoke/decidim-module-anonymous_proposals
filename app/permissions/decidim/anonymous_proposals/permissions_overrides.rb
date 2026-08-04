# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Method overrides to avoid errors when current_user is not present
    module PermissionsOverrides
      extend ActiveSupport::Concern

      def can_create_proposal?
        toggle_allow(
          current_settings&.creation_enabled? &&
          [authorized?(:create), allow_anonymous_proposals? && user.ephemeral?].any?
        )
      end

      private

      def allow_anonymous_proposals?
        Decidim::AnonymousProposals::AnonymousProposalBroker.new(component_settings).allowed?
      end
    end
  end
end
