# frozen_string_literal: true

module Decidim
  module AnonymousProposals
    # Custom helpers, scoped to the anonymous_proposals engine.
    #
    module UserGroupHelper
      # Renders a user_group select field in a form including the anonymous
      # option if enabled
      # form - FormBuilder object
      # name - attribute user_group_id
      # options - A hash used to modify the behavior of the select field.
      #
      # Returns nothing.
      def user_group_with_anonymous_select_field(form, name, options = {})
        return form.select(name, [], options) if skip_user_group_selection?

        select_options = build_user_group_options
        form.select(name, select_options, options)
      end

      private

      def skip_user_group_selection?
        current_user.blank? || user_groups_with_anonymous.empty?
      end

      def build_user_group_options
        user_groups_with_anonymous.map { |group| [group.name, group.id] }
      end

      def user_groups_with_anonymous
        @user_groups_with_anonymous ||= UserGroup.available_for(current_user) + [anonymous_group]
      end
    end
  end
end
