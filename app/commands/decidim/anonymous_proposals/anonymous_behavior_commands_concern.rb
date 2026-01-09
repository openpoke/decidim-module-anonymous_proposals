# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    module AnonymousBehaviorCommandsConcern
      private

      def anonymous?
        @is_anonymous
      end

      def anonymous_user
        Decidim::User.where(organization:).anonymous.first
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
