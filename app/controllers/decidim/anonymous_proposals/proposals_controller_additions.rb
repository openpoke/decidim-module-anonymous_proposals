# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Additions to disable filters
    module ProposalsControllerAdditions
      extend ActiveSupport::Concern

      included do
        helper_method :allow_anonymous_proposals?, :anonymous?, :anonymous_user

        skip_before_action :authenticate_user!, if: :allow_anonymous_proposals?
      end

      private

      def allow_anonymous_proposals?
        component_settings.anonymous_proposals_enabled?
      end

      def anonymous?
        allow_anonymous_proposals? && (current_user.blank? || @proposal&.authored_by?(anonymous_user))
      end

      def anonymous_user
        @anonymous_user ||= Decidim::User.find_or_create_by!(
          organization:,
          email: "anonymous+#{organization.id}@example.org"
        ) do |user|
          user.name = "Anonymous"
          user.nickname = "anonymous_#{organization.id}"
          user.password = SecureRandom.hex(32)
          user.confirmed_at = Time.current
          user.accepted_tos_version = Decidim::Core::Engine.current_settings.accepted_tos_version
          user.admin = false
          user.extended_data = { anonymous: true }
        end
      end
    end
  end
end
