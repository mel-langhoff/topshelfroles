class JobPostingsController < ApplicationController
  def index
    @job_postings = JobPosting
      .includes(:company)
      .order(posted_at: :desc)
      .limit(100)
  end

  def show
    @job_posting = JobPosting.find(params[:id])
  end
end