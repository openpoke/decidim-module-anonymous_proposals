# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    module CoauthorableOverrides
      extend ActiveSupport::Concern

      included do
        def add_coauthor(author, extra_attributes = {})
          return if should_skip_addition?(author, extra_attributes)

          coauthorship_attributes = prepare_coauthorship_attributes(author, extra_attributes)

          if persisted?
            coauthorships.create!(coauthorship_attributes)
          else
            coauthorships.build(coauthorship_attributes)
          end

          authors << author
        end

        private

        def allow_anonymous_proposals?
          component.settings.anonymous_proposals_enabled?
        end

        def anonymous_group
          Decidim::UserGroup.where(organization:).anonymous.first
        end

        def should_skip_addition?(author, extra_attributes)
          return true if author.blank? && persisted?

          user_group = extra_attributes[:user_group]

          if allow_anonymous_proposals? && (author.blank? || user_group == anonymous_group)
            handle_anonymous_proposals(author, extra_attributes)
            return true
          end

          coauthor_exists?(author, user_group)
        end

        def handle_anonymous_proposals(_author, extra_attributes)
          anonymous_group
          extra_attributes.delete(:user_group)
        end

        def coauthor_exists?(author, user_group)
          return true if coauthorships.exists?(decidim_author_id: author.id, decidim_author_type: author.class.base_class.name) && user_group.blank?
          return true if user_group && coauthorships.exists?(user_group:)

          false
        end

        def prepare_coauthorship_attributes(author, extra_attributes)
          extra_attributes.merge(author:)
        end
      end
    end
  end
end
