require "rails_helper"

RSpec.describe "JobPostings", type: :request do
  let!(:search_profile) { create(:search_profile) }

  let!(:company1) { create(:company, name: "Stripe") }
  let!(:company2) { create(:company, name: "Plaid") }

  let!(:job1) do
    create(
      :job_posting,
      company: company1,
      search_profile: search_profile,
      title: "Technical Program Manager",
      remote: true,
      status: "new",
      ai_score: 90,
      posted_at: 1.day.ago,
      apply_url: "https://example.com/job1"
    )
  end

  let!(:job2) do
    create(
      :job_posting,
      company: company2,
      search_profile: search_profile,
      title: "Backend Engineer",
      remote: false,
      status: "saved",
      ai_score: 50,
      posted_at: 2.days.ago,
      apply_url: "https://example.com/job2"
    )
  end

  describe "GET /" do
    it "returns success" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "shows job titles" do
      get root_path

      expect(response.body).to include("Technical Program Manager")
      expect(response.body).to include("Backend Engineer")
    end

    it "orders jobs by score" do
      get root_path

      first_index = response.body.index("Technical Program Manager")
      second_index = response.body.index("Backend Engineer")

      expect(first_index).to be < second_index
    end

    it "filters by title" do
      get root_path, params: { title: "Program" }

      expect(response.body).to include("Technical Program Manager")
      expect(response.body).not_to include("Backend Engineer")
    end

    it "filters by company" do
      get root_path, params: { company: "Stripe" }

      expect(response.body).to include("Technical Program Manager")
      expect(response.body).not_to include("Backend Engineer")
    end

    it "filters by remote" do
      get root_path, params: { remote: "1" }

      expect(response.body).to include("Technical Program Manager")
      expect(response.body).not_to include("Backend Engineer")
    end

    it "filters by status" do
      get root_path, params: { status: "saved" }

      expect(response.body).to include("Backend Engineer")
      expect(response.body).not_to include("Technical Program Manager")
    end
  end

  describe "GET /job_postings/:id" do
    it "shows the job posting" do
      get job_posting_path(job1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Technical Program Manager")
    end
  end

  describe "PATCH /job_postings/:id" do
    it "updates job status" do
      patch job_posting_path(job1), params: {
        job_posting: { status: "applied" }
      }

      expect(response).to redirect_to(root_path)
      expect(job1.reload.status).to eq("applied")
    end
  end
end