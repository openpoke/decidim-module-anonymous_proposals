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
        @editable = proposal.editable_by?(user || anonymous_user)
        @is_anonymous = allow_anonymous_proposals? && user.blank?
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
