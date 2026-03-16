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
      - Do not generate name and contact info unless a docx
      - Keep it concise
      - Do not generate core competencies
      - Use strong action verbs
      - Optimize for ATS keyword matching
      - Emphasize relevant skills
      - Keep professional tone
      - Use bullet points
      - Generate a professional summary that is 2-3 sentences
      - Generate 2 bullet points per job
      - Generate relevant skills and do not make anything up or add any skills
      - Do not include core competencies
      - Do not include "additional qualifications"
      - Do not include anything about references

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