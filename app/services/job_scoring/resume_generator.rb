require "openai"

module JobScoring
  class ResumeGenerator
    def initialize(job)
      @job = job
    end

    def call
      client = OpenAI::Client.new

      resume = JobScoring::ResumeLoader.for_job(@job)

      prompt = <<~PROMPT
      You are a 20 year veteran technical recruiter.

      Rewrite the candidate's resume so it is optimized for the job below.

      Rules:
      - Do not invent experience
      - Keep it concise
      - Use strong action verbs
      - Optimize for ATS keyword matching
      - Emphasize relevant skills
      - Keep professional tone
      - Use bullet points

      Candidate:
      Melissa Langhoff

      Current Resume:
      #{resume}

      Job Title:
      #{@job.title}

      Company:
      #{@job.company&.name}

      Job Description:
      #{@job.description}

      Return a complete optimized resume.
      PROMPT

      response = client.responses.create(
        model: "gpt-4.1-mini",
        input: prompt
      )

      response.output_text

    rescue => e
      Rails.logger.error "RESUME GENERATION ERROR: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      "Unable to generate resume."
    end
  end
end