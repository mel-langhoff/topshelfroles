require "rails_helper"

RSpec.describe JobDiscovery::SearchTerms do
  describe ".list" do
    it "returns an array of search terms" do
      expect(described_class.list).to be_an(Array)
      expect(described_class.list).to include("ruby engineer remote")
    end
  end
end