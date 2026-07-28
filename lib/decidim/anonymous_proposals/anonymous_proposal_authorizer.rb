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

      def anonymous_proposals_enabled?
        Decidim::AnonymousProposals::AnonymousProposalBroker.new(component.settings).allowed?
      end
    end
  end
end
