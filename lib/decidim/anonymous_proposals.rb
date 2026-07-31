# frozen_string_literal: true

require "decidim/anonymous_proposals/admin"
require "decidim/anonymous_proposals/engine"
require "decidim/anonymous_proposals/admin_engine"

module Decidim
  # This namespace holds the logic of the `AnonymousProposals` module
  module AnonymousProposals
    autoload :AnonymousProposalAuthorizer, "decidim/anonymous_proposals/anonymous_proposal_authorizer"
  end
end
