# frozen_string_literal: true

require "rails"
require "decidim/core"
require "deface"

module Decidim
  module AnonymousProposals
    # This is the engine that runs on the public interface of anonymous_proposals.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AnonymousProposals

      routes do
        # Add engine routes here
        # resources :anonymous_proposals
        # root to: "anonymous_proposals#index"
      end

      initializer "decidim_anonymous_proposals.proposal_component_settings" do
        component = Decidim.find_component_manifest(:proposals)
        component.settings(:global) do |settings|
          settings.attribute :anonymous_proposals_enabled, type: :boolean, default: false
        end
      end

      initializer "decidim_anonymous_proposals.data_migrate", after: "decidim_core.data_migrate" do
        DataMigrate.configure do |config|
          config.data_migrations_path << root.join("db/data").to_s
        end
      end

      initializer "decidim_anonymous_proposals.proposals_additions" do
        config.to_prepare do
          Decidim::Proposals::Proposal.class_eval do
            include Decidim::AnonymousProposals::CoauthorableOverrides
          end

          Decidim::Proposals::Permissions.class_eval do
            prepend Decidim::AnonymousProposals::PermissionsOverrides
          end
          Decidim::Proposals::ProposalsController.class_eval do
            include Decidim::AnonymousProposals::AnonymousProposalAdditions
            include Decidim::AnonymousProposals::ProposalsControllerAdditions
          end

          Decidim::AuthorizationModalsController.class_eval do
            include Decidim::AnonymousProposals::AnonymousProposalAdditions
            include Decidim::AnonymousProposals::AuthorizationModalsControllerAdditions
          end

          Decidim::Verifications.register_workflow(:anonymous_proposals_handler) do |workflow|
            workflow.ephemeral = true
            workflow.action_authorizer = "Decidim::AnonymousProposals::AnonymousProposalAuthorizer"
          end
        end

        component = Decidim.find_component_manifest(:proposals)
        component.on(:update) do |instance|
          organization = instance.organization
          if instance.settings.anonymous_proposals_enabled? && organization.available_authorizations.exclude?("anonymous_proposals_handler")
            organization.available_authorizations << "anonymous_proposals_handler"
            # else
            #   We do not disable the authorizations, as there may be other components needing this. So removing it from the organization would create bugs in other components.
            #   organization.available_authorizations.delete("anonymous_proposals_handler")
          end
          organization.save!

          instance.permissions = instance.permissions || {}
          if instance.settings.anonymous_proposals_enabled?
            instance.permissions.deep_merge!({ "withdraw" => { "authorization_handlers" => { "anonymous_proposals_handler" => {} } } })
          else
            instance.permissions.dig("withdraw", "authorization_handlers")&.delete("anonymous_proposals_handler")
            instance.permissions["withdraw"]&.compact_blank!
            instance.permissions&.compact_blank!
          end
          instance.save!
        end

        component.on(:create) do |instance|
          organization = instance.organization
          if instance.settings.anonymous_proposals_enabled? && organization.available_authorizations.exclude?("anonymous_proposals_handler")
            organization.available_authorizations << "anonymous_proposals_handler"
            # else
            #   We do not disable the authorizations, as there may be other components needing this. So removing it from the organization would create bugs in other components.
            #   organization.available_authorizations.delete("anonymous_proposals_handler")
          end
          organization.save!

          instance.permissions = instance.permissions || {}
          if instance.settings.anonymous_proposals_enabled?
            instance.permissions.deep_merge!({ "withdraw" => { "authorization_handlers" => { "anonymous_proposals_handler" => {} } } })
          else
            instance.permissions.dig("withdraw", "authorization_handlers")&.delete("anonymous_proposals_handler")
            instance.permissions["withdraw"]&.compact_blank!
            instance.permissions&.compact_blank!
          end
          instance.save!
        end
      end
    end
  end
end
