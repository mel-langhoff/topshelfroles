require "openai"
require "json"

module JobScoring
  class AiJobScorer
    def initialize(job)
      @job = job
    end

    def call
      return unless @job.description.present?

      client = OpenAI::Client.new
      resume = JobScoring::ResumeLoader.for_job(@job)

      prompt = <<~PROMPT
        You are an expert technical recruiter.

        Compare the following resume with the job description.

        Resume:
        #{resume}

        Job Title:
        #{@job.title}

        Company:
        #{@job.company&.name}

        Job Description:
        #{@job.description}

        Score the match from 0 to 100.

        Return ONLY valid JSON in this format:

        {
          "score": 85,
          "reason": "Strong match for SaaS platform delivery and API systems."
        }
      PROMPT

      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [
            { role: "user", content: prompt }
          ],
          temperature: 0.2
        }
      )

      content = response.dig("choices", 0, "message", "content")

      return unless content.present?

      # Fix common AI JSON mistakes (trailing commas)
      clean_json = content.gsub(/,\s*}/, "}")

      data = JSON.parse(clean_json) rescue {}

      @job.update!(
        ai_score: data["score"] || 0,
        ai_reason: data["reason"] || data["summary"]
      )

    rescue => e
      Rails.logger.error("AI scoring failed: #{e.message}")
      @job.update(ai_score: 0)
    end
  end
end