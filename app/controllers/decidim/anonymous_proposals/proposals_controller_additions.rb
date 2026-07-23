# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Additions to disable filters
    module ProposalsControllerAdditions
      extend ActiveSupport::Concern

      included do
        helper_method :allow_anonymous_proposals?

        prepend_before_action :set_ephemeral_user, if: :allow_anonymous_proposals?
      end

      private

      def set_ephemeral_user
        if user_signed_in?
          update_onboarding_data
        else
          create_ephemeral_user
        end
      end

      def update_onboarding_data
        return unless current_user.ephemeral?

        current_user.update(extended_data: current_user.extended_data.deep_merge("onboarding" => current_onboarding_data))
      end

      def create_ephemeral_user
        form = Decidim::EphemeralUserForm.new(
          organization: current_organization,
          onboarding_data: current_onboarding_data
        )
        CreateEphemeralUser.call(form) do
          on(:ok) do |ephemeral_user|
            sign_in(ephemeral_user)
          end
        end
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
