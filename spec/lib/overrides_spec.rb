# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-proposals",
    files: {
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "c37b628d7426f957d1340a4b40ab6787",
      "/app/commands/decidim/proposals/create_proposal.rb" => "f88c0aa5b5927410707bc356eef8f544",
      "/app/commands/decidim/proposals/update_proposal.rb" => "aac67a59183b35341471013407b7da7e",
      "/app/commands/decidim/proposals/publish_proposal.rb" => "e09c81d15493760f736d6b2020bae98c",
      "/app/permissions/decidim/proposals/permissions.rb" => "6618dfe4b3cf7cfcd9ed338b282dbd7e",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "ba8c88bdf07061fda1962c54868c9131",
      "/app/views/decidim/proposals/proposals/index.html.erb" => "cd4be96ca73de79b0f8d82f0f80f00e7",
      "/app/views/decidim/proposals/proposals/edit_draft.html.erb" => "3e51c7a14d250a1abef0753a1db7661b"
    },
    package: "decidim-core",
    files: {
      "/lib/decidim/coauthorable.rb" => "0f7654ef8a968942b391dd671b27d06c"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
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
