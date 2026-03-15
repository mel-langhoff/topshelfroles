require "rails_helper"

RSpec.describe JobSources::GreenhouseSource, :vcr do
  it "fetches jobs from greenhouse" do
    source = described_class.new

    jobs = source.fetch_jobs

    expect(jobs).to be_an(Array)
    expect(jobs).not_to be_empty
    expect(jobs.first).to include(
      :title,
      :company_name,
      :apply_url
    )
  end
end