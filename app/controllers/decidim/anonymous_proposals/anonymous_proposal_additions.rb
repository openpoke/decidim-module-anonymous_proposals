# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    module AnonymousProposalAdditions
      extend ActiveSupport::Concern

      def create_ephemeral_user
        return if user_signed_in?

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
    end
  end
end
