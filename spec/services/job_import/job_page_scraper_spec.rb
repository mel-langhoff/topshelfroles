require "rails_helper"

RSpec.describe JobImport::JobPageScraper do
  let(:url) { "https://example.com/job" }
  let(:html) do
    <<~HTML
      <html>
        <head>
          <title>Senior Ruby Developer</title>
        </head>
        <body>
          <p>This is a remote job based in Denver, CO.</p>
        </body>
      </html>
    HTML
  end

  let(:ai_response) do
    {
      "location" => "Denver, CO",
      "remote" => true
    }
  end

  before do
    allow_any_instance_of(JobImport::JobPageScraper)
      .to receive(:fetch_page)
      .and_return(html)

    allow_any_instance_of(AiLocationExtractor)
      .to receive(:extract)
      .and_return(ai_response)

    allow(SearchProfile).to receive(:first).and_return(create(:search_profile))
  end

  describe "#call" do
    it "creates a job posting with AI extracted location" do
      expect {
        described_class.new(url).call
      }.to change(JobPosting, :count).by(1)

      job = JobPosting.last

      expect(job.title).to eq("Senior Ruby Developer")
      expect(job.remote).to eq(true)
      expect(job.description).to include("remote job")
    end

    it "creates the company from the domain" do
      described_class.new(url).call

      expect(Company.last.name).to eq("example.com")
    end
  end
end