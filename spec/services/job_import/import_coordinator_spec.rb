require "rails_helper"

RSpec.describe JobImport::ImportCoordinator do
  let!(:search_profile) do
    create(
      :search_profile,
      target_titles: "technical program manager,solutions engineer,backend engineer",
      target_skills: "ruby,rails,api,saas",
      keywords: "remote,delivery"
    )
  end

  let(:source) do
    instance_double(
      JobSources::GreenhouseSource,
      fetch_jobs: [
        {
          external_id: "1",
          source_name: "greenhouse",
          company_name: "Stripe",
          title: "Technical Program Manager",
          location_text: "Remote, United States",
          remote: true,
          apply_url: "https://example.com/job/1",
          description: "Lead API platform delivery",
          posted_at: Time.current
        },
        {
          external_id: "2",
          source_name: "greenhouse",
          company_name: "NopeCorp",
          title: "Office Manager",
          location_text: "Denver, Colorado",
          remote: false,
          apply_url: "https://example.com/job/2",
          description: "Office admin work",
          posted_at: Time.current
        }
      ]
    )
  end

  it "imports only jobs that pass filters" do
    coordinator = described_class.new(sources: [source], search_profile: search_profile)

    expect { coordinator.call }.to change(JobPosting, :count).by(1)

    job = JobPosting.last
    expect(job.title).to eq("Technical Program Manager")
    expect(job.company.name).to eq("Stripe")
  end

  it "does not duplicate existing jobs by apply_url" do
    coordinator = described_class.new(sources: [source], search_profile: search_profile)

    coordinator.call

    expect { coordinator.call }.not_to change(JobPosting, :count)
  end
end