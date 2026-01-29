# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Method overrides to avoid errors when current_user is not present
    module CreateProposalCommandOverrides
      extend ActiveSupport::Concern

      include Decidim::AnonymousProposals::AnonymousBehaviorCommandsConcern

      def initialize(form, user, coauthorships = nil)
        @form = form
        @is_anonymous = allow_anonymous_proposals? && user.blank?

        self.current_user = user
        @coauthorships = coauthorships
      end

      private

      def component
        @component ||= form.current_component
      end
    end
  end
end
