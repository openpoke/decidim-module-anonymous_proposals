# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    module CoauthorableOverrides
      extend ActiveSupport::Concern

      included do
        def add_coauthor(author, extra_attributes = {})
          return if coauthorships.exists?(decidim_author_id: author.id, decidim_author_type: author.class.base_class.name)

          coauthorship_attributes = extra_attributes.merge(author:)

          if persisted?
            coauthorships.create!(coauthorship_attributes)
          else
            coauthorships.build(coauthorship_attributes)
          end

          authors << author
        end
      end
    end
  end
end
