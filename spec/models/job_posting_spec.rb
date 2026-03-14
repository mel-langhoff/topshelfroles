require "rails_helper"

RSpec.describe JobPosting, type: :model do
  subject(:job_posting) { build(:job_posting) }

  describe "associations" do
    it { should belong_to(:company) }
    it { should belong_to(:search_profile) }
    it { should have_one(:job_application).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:apply_url) }
    it { should validate_uniqueness_of(:apply_url) }
  end

  describe "scopes" do
    let!(:remote_job)   { create(:job_posting, remote: true, excluded: false, posted_at: 2.days.ago, ai_score: 90) }
    let!(:onsite_job)   { create(:job_posting, remote: false, excluded: false, posted_at: 2.days.ago, ai_score: 70) }
    let!(:excluded_job) { create(:job_posting, remote: true, excluded: true, posted_at: 2.days.ago, ai_score: 95) }
    let!(:old_job)      { create(:job_posting, remote: true, excluded: false, posted_at: 30.days.ago, ai_score: 60) }

    it "returns only remote jobs for remote_only" do
      expect(JobPosting.remote_only).to include(remote_job)
      expect(JobPosting.remote_only).not_to include(onsite_job)
    end

    it "returns only non-excluded jobs for active" do
      expect(JobPosting.active).to include(remote_job)
      expect(JobPosting.active).not_to include(excluded_job)
    end

    it "returns only recent jobs for recent" do
      expect(JobPosting.recent).to include(remote_job)
      expect(JobPosting.recent).not_to include(old_job)
    end

    it "orders by ai_score descending for ordered_by_score" do
      expect(JobPosting.ordered_by_score.first).to eq(excluded_job)
    end
  end

  describe "#workday?" do
    it "returns true when apply_url contains workday" do
      job = build(:job_posting, apply_url: "https://company.workday.com/job/123")
      expect(job.workday?).to be(true)
    end

    it "returns false when apply_url does not contain workday" do
      job = build(:job_posting, apply_url: "https://jobs.ashbyhq.com/company/123")
      expect(job.workday?).to be(false)
    end
  end
end