# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    module AnonymousBehaviorCommandsConcern
      private

      def anonymous?
        @is_anonymous
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

      def current_user=(user)
        @current_user = anonymous? ? anonymous_user : user
      end

      def allow_anonymous_proposals?
        component.settings.anonymous_proposals_enabled?
      end

      def organization
        @organization ||= component.organization
      end
    end
  end
end
