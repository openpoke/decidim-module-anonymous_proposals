# frozen_string_literal: true

DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.32-stable" }.freeze

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-anonymous_proposals", path: "."

gem "bootsnap", "~> 1.24"
gem "puma", ">= 6.3.1"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", ">= 11", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "decidim-initiatives", DECIDIM_VERSION
  gem "rubocop-performance", "~> 1.25"
end

group :development do
  gem "faker", "~> 3.2"
  gem "letter_opener_web"
  gem "listen"
  gem "web-console", "~> 4.3"
end
