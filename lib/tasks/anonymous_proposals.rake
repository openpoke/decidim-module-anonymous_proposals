# frozen_string_literal: true

namespace :decidim_anonymous_proposals do
  desc "Create anonymous users for organizations"
  task :generate_anonymous_user, [:name, :nickname, :email, :organization_id] => :environment do |_, args|
    organizations = args.organization_id.present? ? Decidim::Organization.where(id: args.organization_id) : Decidim::Organization.all

    organizations.each do |organization|
      anonymous = Decidim::User.find_or_initialize_by(
        organization:,
        email: args.email || "anonymous+#{organization.id}@example.org"
      )

      anonymous.name = args.name || "Anonymous"
      anonymous.nickname = args.nickname || "anonymous_#{organization.id}"
      anonymous.password ||= SecureRandom.hex(32)
      anonymous.confirmed_at = Time.current
      anonymous.accepted_tos_version ||= Decidim::Core::Engine.current_settings.accepted_tos_version
      anonymous.tos_agreement = true
      anonymous.admin = false
      anonymous.extended_data ||= {}
      anonymous.extended_data[:anonymous] = true
      anonymous.save!
    end
  end
end
