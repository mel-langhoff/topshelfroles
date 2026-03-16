require "openai"

module JobScoring
  class CoverLetterGenerator
    def initialize(job)
      @job = job
    end

    def call
      client = OpenAI::Client.new

      resume = JobScoring::ResumeLoader.for_job(@job)

      prompt = <<~PROMPT
      You are a 20 year veteran of tech recruiting that works at the top headhunter agency in the nation. Write a cover letter for the resume and information below and follow the instructions.

      Candidate:
      Melissa Langhoff

      Resume:
      #{resume}

      Job Title:
      #{@job.title}

      Company:
      #{@job.company&.name}

      Job Description:
      #{@job.description}

      Requirements:
      - Professional tone in the voice on the resume
      - 2.5-3 paragraphs
      - 2-3 sentences per paragraph
      - Make it punchy
      - Use active language
      - Make it human
      - Highlight relevant experience
      - Mention the company name
      - Do not invent experience
      - No placeholders
      PROMPT

      response = client.responses.create(
        model: "gpt-4.1-mini",
        input: prompt
      )

      response.output_text

    rescue => e
      Rails.logger.error "COVER LETTER ERROR: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      "OpenAI error: #{e.message}"
    end
  end
end