# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Method overrides to avoid errors when current_user is not present
    module PermissionsOverrides
      extend ActiveSupport::Concern

      private

      def user_or_anonymous_action?(permission_action)
        user || ([:create, :edit].include?(permission_action.action) && allow_anonymous_proposals?)
      end

      def allow_anonymous_proposals?
        Decidim::User.where(organization:).anonymous.exists? && component_settings.anonymous_proposals_enabled?
      end

      def organization
        @organization ||= context.fetch(:organization, nil) || context.fetch(:current_organization, nil)
      end

      def can_edit_proposal?
        toggle_allow(proposal && (proposal.editable_by?(user) || anonymously_editable?))
      end

      def can_create_proposal?
        toggle_allow(authorized?(:create) && current_settings&.creation_enabled? && allow_anonymous_proposals?)
      end

      def anonymously_editable?
        allow_anonymous_proposals? && proposal.draft? && proposal.editable_by?(Decidim::User.where(organization:).anonymous.first)
      end
    end
  end
end
