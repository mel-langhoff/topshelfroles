require "rails_helper"

RSpec.describe JobImport::ImportCoordinator do
  let!(:search_profile) do
    create(
      :search_profile,
      target_titles: "technical program manager,backend engineer",
      target_skills: "ruby,rails,api",
      keywords: "remote"
    )
  end

  let(:source) { instance_double("JobSource") }

  let(:raw_job) do
    {
      source_name: "test_source",
      company_name: "Stripe",
      title: "Technical Program Manager",
      apply_url: "https://example.com/job/123",
      description: "Remote role building APIs",
      remote: true,
      posted_at: Time.current
    }
  end

before do
  allow(source).to receive(:fetch_jobs).and_return([raw_job])

  # make filter always pass during this test
  allow_any_instance_of(JobImport::Filter)
    .to receive(:passes?)
    .and_return(true)

  # stub scoring so it doesn't interfere with test
  allow_any_instance_of(JobScoring::JobMatchScorer)
    .to receive(:call)
    .and_return(50)
end

  describe "#call" do
    it "imports a job posting" do
      expect {
        described_class.new(sources: [source], search_profile: search_profile).call
      }.to change(JobPosting, :count).by(1)

      job = JobPosting.last

      expect(job.title).to eq("Technical Program Manager")
      expect(job.company.name).to eq("Stripe")
      expect(job.search_profile).to eq(search_profile)
    end

    it "runs the job scorer" do
      described_class.new(sources: [source], search_profile: search_profile).call

      job = JobPosting.last

      expect(job.ai_score).not_to be_nil
    end

    it "does not duplicate jobs with the same apply_url" do
      coordinator = described_class.new(sources: [source], search_profile: search_profile)

      coordinator.call
      coordinator.call

      expect(JobPosting.count).to eq(1)
    end
  end
end