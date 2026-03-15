require "rails_helper"

RSpec.describe JobSources::LeverSource, :vcr do
  it "fetches jobs from lever" do
    source = described_class.new

    jobs = source.fetch_jobs

    expect(jobs).to be_an(Array)

    if jobs.any?
      expect(jobs.first).to include(
        :title,
        :company_name,
        :apply_url
      )
    end
  end
end