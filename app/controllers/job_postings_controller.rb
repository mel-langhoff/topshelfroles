class JobPostingsController < ApplicationController
  def index
    @job_postings = JobPosting.includes(:company)

    # Title filter
    if params[:title].present?
      @job_postings = @job_postings.where(
        "job_postings.title ILIKE ?", "%#{params[:title]}%"
      )
    end

    # Company filter
    if params[:company].present?
      @job_postings = @job_postings
        .joins(:company)
        .where("companies.name ILIKE ?", "%#{params[:company]}%")
    end

    # Location filters
    if params[:location].present?

      if params[:location] == "us"
        @job_postings = @job_postings.where(
          "job_postings.remote = TRUE OR job_postings.location ILIKE ? OR job_postings.location ILIKE ? OR job_postings.location ILIKE ?",
          "%united states%",
          "%usa%",
          "%us%"
        )
      end

      if params[:location] == "colorado"
        @job_postings = @job_postings.where(
          "job_postings.location ILIKE ?",
          "%colorado%"
        )
      end

    end

    # Remote filter
    if params[:remote] == "1"
      @job_postings = @job_postings.where(remote: true)
    end

    # Status filter
    if params[:status].present?
      @job_postings = @job_postings.where(status: params[:status])
    end

    # Sorting
    if params[:sort] == "recent"
      @job_postings = @job_postings.order(posted_at: :desc)
    else
      @job_postings = @job_postings.order(ai_score: :desc, posted_at: :desc)
    end

    # Limit results
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

  def refresh
    JobImport::ImportCoordinator.new.call
    redirect_to root_path, notice: "Jobs refreshed."
  end

  private

  def job_posting_params
    params.require(:job_posting).permit(:status)
  end
end