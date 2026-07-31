# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    class AnonymousProposalAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
      def authorize
        status_code, data = *super

        status_code = :ok if component && component.manifest.name == :proposals && anonymous_proposals_enabled?

        [status_code, data]
      end

      private

      delegate :settings, to: :component
      delegate :anonymous_proposals_enabled?, to: :settings
    end
  end
end
