# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Additions to disable filters
    module ProposalsControllerAdditions
      extend ActiveSupport::Concern

      included do
        helper_method :allow_anonymous_proposals?

        prepend_before_action :set_ephemeral_user, except: [:index, :show] # rubocop:disable Rails/LexicallyScopedActionFilter
      end

      private

      def set_ephemeral_user
        return unless allow_anonymous_proposals?

        create_ephemeral_user
        update_onboarding_data
      end

      def update_onboarding_data
        return unless current_user&.ephemeral?

        extended_data = current_user.extended_data || {}
        current_user.update(extended_data: extended_data.deep_merge("onboarding" => current_onboarding_data))
      end

      def current_onboarding_data
        {
          "component" => current_component.to_gid,
          "model" => @proposal&.to_gid
        }
      end

      def allow_anonymous_proposals?
        component_settings.anonymous_proposals_enabled?
      end
    end
  end
end
