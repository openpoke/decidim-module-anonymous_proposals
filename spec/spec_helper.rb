# frozen_string_literal: true

require "decidim/dev"
begin
  require "decidim/initiatives"
rescue LoadError # rubocop:disable Lint/SuppressedException
end

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join("spec", "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"
