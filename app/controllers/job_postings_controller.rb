
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

    # Location filter
    if params[:location].present?
      case params[:location]

      when "us"
        @job_postings = @job_postings.where(
          "job_postings.location ILIKE ANY (ARRAY[?, ?, ?])",
          "%united states%",
          "%usa%",
          "%us%"
        )

      when "colorado"
        @job_postings = @job_postings.where(
          "job_postings.location ILIKE ANY (ARRAY[?, ?, ?])",
          "%colorado%",
          "%denver%",
          "%boulder%"
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

    # Limit
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

#   def analyze
#   job = JobPosting.find(params[:id])

#   JobScoring::JobMatchScorer.new(job).call

#   redirect_to root_path, notice: "AI analysis complete."
# end

def analyze
  @job = JobPosting.find(params[:id])

  # run AI analysis
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
    Rails.logger.error "Markdown file: #{md_path}"
    Rails.logger.error "Template: #{template}"
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
# class JobPostingsController < ApplicationController
#   def index
#     @job_postings = JobPosting.includes(:company)

#     # Title filter
#     if params[:title].present?
#       @job_postings = @job_postings.where(
#         "job_postings.title ILIKE ?", "%#{params[:title]}%"
#       )
#     end

#     # Company filter
#     if params[:company].present?
#       @job_postings = @job_postings
#         .joins(:company)
#         .where("companies.name ILIKE ?", "%#{params[:company]}%")
#     end

#     # Location filters
#     if params[:location].present?

#       if params[:location] == "us"
#         @job_postings = @job_postings.where(
#           "job_postings.remote = TRUE OR job_postings.location ILIKE ? OR job_postings.location ILIKE ? OR job_postings.location ILIKE ?",
#           "%united states%",
#           "%usa%",
#           "%us%"
#         )
#       end

#       if params[:location] == "colorado"
#         @job_postings = @job_postings.where(
#           "job_postings.location ILIKE ?",
#           "%colorado%"
#         )
#       end

#     end

#     # Remote filter
#     if params[:remote] == "1"
#       @job_postings = @job_postings.where(remote: true)
#     end

#     # Status filter
#     if params[:status].present?
#       @job_postings = @job_postings.where(status: params[:status])
#     end

#     # Sorting
#     if params[:sort] == "recent"
#       @job_postings = @job_postings.order(posted_at: :desc)
#     else
#       @job_postings = @job_postings.order(ai_score: :desc, posted_at: :desc)
#     end

#     # Limit results
#     @job_postings = @job_postings.limit(200)
#   end

#   def show
#     @job_posting = JobPosting.find(params[:id])
#   end

#   def update
#     @job_posting = JobPosting.find(params[:id])

#     if @job_posting.update(job_posting_params)
#       redirect_to root_path, notice: "Job updated."
#     else
#       redirect_to root_path, alert: "Could not update job."
#     end
#   end

#   def refresh
#     JobImport::ImportCoordinator.new.call
#     redirect_to root_path, notice: "Jobs refreshed."
#   end

#   def generate_resume
#   job = JobPosting.find(params[:id])

#   resume_text = load_resumes

#   prompt = <<~PROMPT
#     You are an expert resume writer.

#     Rewrite the following resume so it is optimized for this job.

#     JOB DESCRIPTION:
#     #{job.description}

#     CURRENT RESUME:
#     #{resume_text}

#     Output a clean professional resume.
#   PROMPT

#   response = OpenAiService.new.chat_completion(
#     messages: [
#       { role: "user", content: prompt }
#     ]
#   )

#   @generated_resume = response

#   render :resume
# end

# def resume_pdf
#   @job = JobPosting.find(params[:id])

#   resume_text = load_resumes

#   prompt = <<~PROMPT
#   Rewrite this resume to match the job description.

#   JOB DESCRIPTION:
#   #{@job.description}

#   RESUME:
#   #{resume_text}

#   Return a clean professional resume.
#   PROMPT

#   @generated_resume = OpenAiService.new.chat_completion(
#     messages: [{ role: "user", content: prompt }]
#   )

#   respond_to do |format|
#     format.pdf do
#       render pdf: "resume_#{@job.company.name.parameterize}",
#              template: "job_postings/resume_pdf",
#              layout: "pdf",
#              disposition: "attachment"
#     end
#   end
# end

#   private

#   def job_posting_params
#     params.require(:job_posting).permit(:status)
#   end

#   def load_resumes
#   resume1 = File.read(Rails.root.join("config/data/Melissa Langhoff_resume.txt"))
#   resume2 = File.read(Rails.root.join("config/data/Melissa Langhoff_CS_resume.txt"))

#   "#{resume1}\n\n#{resume2}"
# end
# end