# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overridden is the same
# as the expected. If this test fails, it means that the overridden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-proposals",
    files: {
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "5f0946cb500e390a4a8f02857fbe9646",
      "/app/commands/decidim/proposals/create_proposal.rb" => "3d7cfe8f5d1eea00594ce29c4b37985b",
      "/app/commands/decidim/proposals/update_proposal.rb" => "0a908738027f7149f7aebf34a43c0530",
      "/app/commands/decidim/proposals/publish_proposal.rb" => "e09c81d15493760f736d6b2020bae98c",
      "/app/permissions/decidim/proposals/permissions.rb" => "a85b7e018f419041ed21b5b26d211d73",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "ba8c88bdf07061fda1962c54868c9131",
      "/app/views/decidim/proposals/proposals/index.html.erb" => "e3733b41a9bb2feca2faa1c0ef725ee3",
      "/app/views/decidim/proposals/proposals/_proposal_actions.html.erb" => "cd221a317b9eb2b57cc505d09d10f3e8",
      "/app/views/decidim/proposals/proposals/edit_draft.html.erb" => "3e51c7a14d250a1abef0753a1db7661b"
    }
  },
  {
    package: "decidim-core",
    files: {
      "/lib/decidim/coauthorable.rb" => "3e1a221c52cada5a5cdd38009737a186"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package]) # rubocop:disable RSpec/LeakyLocalVariable
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
