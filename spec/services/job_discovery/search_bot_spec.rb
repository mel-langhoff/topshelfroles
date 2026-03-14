require "rails_helper"

RSpec.describe JobDiscovery::SearchBot do
  describe "#run" do
    let(:query_response_body) do
      {
        "RelatedTopics" => [
          { "FirstURL" => "https://jobs.example.com/role/123" },
          { "FirstURL" => "https://jobs.example.com/role/456" }
        ]
      }.to_json
    end

    let(:response) do
      instance_double(Net::HTTPSuccess, is_a?: true, body: query_response_body)
    end

    before do
      allow(JobDiscovery::QueryBuilder).to receive(:build).and_return(
        ["site:linkedin.com ruby engineer remote"]
      )

      allow(Net::HTTP).to receive(:get_response).and_return(response)

      scraper = instance_double(JobImport::JobPageScraper, call: true)
      allow(JobImport::JobPageScraper).to receive(:new).and_return(scraper)
    end

    it "searches queries and sends discovered urls to the scraper" do
      described_class.new.run

      expect(JobImport::JobPageScraper).to have_received(:new).with("https://jobs.example.com/role/123")
      expect(JobImport::JobPageScraper).to have_received(:new).with("https://jobs.example.com/role/456")
    end
  end
end