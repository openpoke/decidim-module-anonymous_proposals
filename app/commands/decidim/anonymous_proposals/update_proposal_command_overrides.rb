# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Method overrides to avoid errors when current_user is not present
    module UpdateProposalCommandOverrides
      extend ActiveSupport::Concern

      include Decidim::AnonymousProposals::AnonymousBehaviorCommandsConcern

      def initialize(form, user, proposal)
        @form = form
        @proposal = proposal
        @attached_to = proposal
        @editable = (allow_anonymous_proposals? && proposal.authored_by?(anonymous_user)) || proposal.editable_by?(user)
        @is_anonymous = allow_anonymous_proposals? && (user.blank? || (proposal.published? && proposal.authored_by?(anonymous_user)))
        self.current_user = user
      end

      private

      def component
        @component ||= form.current_component
      end

      def invalid?
        !@editable || form.invalid? || proposal_limit_reached?
      end
    end
  end
end
