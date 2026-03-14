require "rails_helper"

RSpec.describe JobDiscovery::QueryBuilder do
  describe ".build" do
    before do
      allow(JobDiscovery::SearchDomains).to receive(:list).and_return(
        ["linkedin.com", "wellfound.com"]
      )

      allow(JobDiscovery::SearchTerms).to receive(:list).and_return(
        ["ruby engineer remote", "rails developer"]
      )
    end

    it "builds site-specific search queries for each domain and term" do
      queries = described_class.build

      expect(queries).to contain_exactly(
        "site:linkedin.com ruby engineer remote",
        "site:linkedin.com rails developer",
        "site:wellfound.com ruby engineer remote",
        "site:wellfound.com rails developer"
      )
    end
  end
end