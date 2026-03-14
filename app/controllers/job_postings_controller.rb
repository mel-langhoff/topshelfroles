class JobPostingsController < ApplicationController
  def index
    @job_postings = JobPosting
      .includes(:company)
      .order(ai_score: :desc)

    if params[:title].present?
      @job_postings = @job_postings.where(
        "job_postings.title ILIKE ?", "%#{params[:title]}%"
      )
    end

    if params[:company].present?
      @job_postings = @job_postings
        .joins(:company)
        .where("companies.name ILIKE ?", "%#{params[:company]}%")
    end

    if params[:remote] == "1"
      @job_postings = @job_postings.where(remote: true)
    end

    if params[:status].present?
      @job_postings = @job_postings.where(status: params[:status])
    end

    @job_postings = @job_postings.limit(200)
  end

  def show
    @job_posting = JobPosting.find(params[:id])
  end

  def update
    @job_posting = JobPosting.find(params[:id])

    if @job_posting.update(job_posting_params)
      redirect_to root_path, notice: "Job updated."
    else
      redirect_to root_path, alert: "Could not update job."
    end
  end

  private

  def job_posting_params
    params.require(:job_posting).permit(:status)
  end
end