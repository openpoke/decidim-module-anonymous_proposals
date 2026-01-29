# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Method overrides to avoid errors when current_user is not present
    module PublishProposalCommandOverrides
      extend ActiveSupport::Concern

      include Decidim::AnonymousProposals::AnonymousBehaviorCommandsConcern

      def initialize(proposal, user)
        @proposal = proposal
        @is_anonymous = allow_anonymous_proposals? && (user.blank? || proposal.authored_by?(anonymous_user))
        self.current_user = user
      end

      private

      def component
        @component ||= @proposal.component
      end
    end
  end
end
