# frozen_string_literal: true

class AddAuthorizationHandler < ActiveRecord::Migration[8.1]
  def up
    Decidim::Component.where(manifest_name: "proposals").find_each do |instance|
      next unless instance.settings.anonymous_proposals_enabled?

      instance.permissions = instance.permissions || {}
      instance.permissions.deep_merge!({ "withdraw" => { "authorization_handlers" => { "anonymous_proposals_handler" => {} } } })
      instance.save!

      organization = instance.organization

      next if organization.available_authorizations.include?("anonymous_proposals_handler")

      organization.available_authorizations << "anonymous_proposals_handler"
      organization.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
