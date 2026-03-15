require "rails_helper"

RSpec.describe JobPosting, type: :model do
  describe "associations" do
    it { should belong_to(:company) }
    it { should belong_to(:search_profile) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:apply_url) }
  end

  describe "status validation" do
    it "allows valid statuses" do
      JobPosting::STATUSES.each do |status|
        job = build(:job_posting, status: status)
        expect(job).to be_valid
      end
    end

    it "rejects invalid status" do
      job = build(:job_posting, status: "banana")
      expect(job).not_to be_valid
    end
  end
end