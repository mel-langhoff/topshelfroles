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

  # LOCATION filter
  if params[:location] == "us"
    @job_postings = @job_postings.where(
      "job_postings.remote = TRUE
       OR job_postings.location ILIKE ?
       OR job_postings.location ILIKE ?
       OR job_postings.location ILIKE ?
       OR job_postings.location ILIKE ?",
      "%united states%",
      "%usa%",
      "%america%",
      "%us%"
    )

  elsif params[:location] == "colorado"
    @job_postings = @job_postings.where(
      "job_postings.location ILIKE ?
       OR job_postings.location ILIKE ?
       OR job_postings.location ILIKE ?",
      "%colorado%",
      "%denver%",
      "%boulder%"
    )
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

  @job_postings = @job_postings.limit(100)
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


  def analyze
    @job = JobPosting.find(params[:id])
    JobScoring::JobMatchScorer.new(@job).call
    render :analyze
  end


  def cover_letter
    job = JobPosting.find(params[:id])
    @cover_letter = JobScoring::CoverLetterGenerator.new(job).call
  end


  def resume
    job = JobPosting.find(params[:id])
    @resume = JobScoring::ResumeGenerator.new(job).call
  end


  def download_resume
    @job_posting = JobPosting.find(params[:id])
    @resume = JobScoring::ResumeGenerator.new(@job_posting).call

    company_name = @job_posting.company&.name&.parameterize || "company"

    render pdf: "Melissa_Langhoff_Resume_#{company_name}",
           template: "job_postings/resume",
           layout: "pdf",
           disposition: "attachment",
           encoding: "UTF-8"
  end


  def download_resume_docx
    @job_posting = JobPosting.find(params[:id])

    resume_markdown = JobScoring::ResumeGenerator.new(@job_posting).call
    company_name = @job_posting.company&.name&.parameterize || "company"

    md_path   = Rails.root.join("tmp", "resume_#{company_name}.md")
    docx_path = Rails.root.join("tmp", "resume_#{company_name}.docx")

    File.write(md_path, resume_markdown)

    pandoc_path = "C:/Program Files/Pandoc/pandoc.exe"
    template    = Rails.root.join("app", "docx_templates", "resume_template.docx")

    success = system(
      pandoc_path,
      md_path.to_s,
      "-f", "markdown",
      "-o", docx_path.to_s,
      "--reference-doc=#{template}"
    )

    unless success && File.exist?(docx_path)
      Rails.logger.error "Pandoc failed to generate DOCX"
      render plain: "DOCX generation failed", status: 500
      return
    end

    send_file docx_path,
              filename: "Melissa_Langhoff_Resume_#{company_name}.docx",
              type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  end


  private

  def job_posting_params
    params.require(:job_posting).permit(:status)
  end

end