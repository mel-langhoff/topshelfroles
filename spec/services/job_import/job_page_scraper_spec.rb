require "rails_helper"

RSpec.describe JobImport::JobPageScraper do
  describe "#call" do
    let!(:search_profile) { create(:search_profile) }

    let(:url) { "https://jobs.example.com/role/123" }
    let(:html) do
      <<~HTML
        <html>
          <head>
            <title>Senior Ruby Engineer</title>
          </head>
          <body>
            <h1>Senior Ruby Engineer</h1>
            <p>Remote role in the United States working on Rails APIs.</p>
          </body>
        </html>
      HTML
    end

    let(:response) do
      instance_double(Net::HTTPSuccess, is_a?: true, body: html)
    end

    before do
      allow(Net::HTTP).to receive(:get_response).and_return(response)
    end

    it "creates a job posting from the scraped page" do
      expect {
        described_class.new(url).call
      }.to change(JobPosting, :count).by(1)

      job = JobPosting.last
      expect(job.title).to eq("Senior Ruby Engineer")
      expect(job.apply_url).to eq(url)
    end

    it "creates a company based on the host" do
      described_class.new(url).call

      expect(Company.last.name).to eq("jobs.example.com")
    end
  end
end