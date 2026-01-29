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
        anonymous_user.present? && component_settings.anonymous_proposals_enabled?
      end

      def anonymous?
        allow_anonymous_proposals? && (current_user.blank? || @proposal&.authored_by?(anonymous_user))
      end

      def anonymous_user
        @anonymous_user ||= Decidim::User.where(organization: current_organization).anonymous.first
      end

      def anonymous_user_present?
        Decidim::User.where(organization: current_organization).anonymous.exists?
      end
    end
  end
end
