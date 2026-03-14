require "rails_helper"

RSpec.describe JobDiscovery::SearchDomains do
  describe ".list" do
    it "returns an array of domains" do
      expect(described_class.list).to be_an(Array)
      expect(described_class.list).to include("linkedin.com")
    end
  end
end