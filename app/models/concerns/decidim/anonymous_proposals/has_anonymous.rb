# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    module HasAnonymous
      extend ActiveSupport::Concern

      included do
        # Use IS NOT NULL because binding a parameter with IS is invalid in PostgreSQL
        scope :anonymous, -> { where("extended_data->>'anonymous' IS NOT NULL") }
      end
    end
  end
end
