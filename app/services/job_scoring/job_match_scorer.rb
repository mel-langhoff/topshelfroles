require "openai"

module JobScoring
  class JobMatchScorer
    def initialize(job)
      @job = job
    end

    def call
      resume = load_resume
      return unless resume

      score = score_job(resume)

      @job.update(ai_score: score)
    end

    private

    def load_resume
      path = Rails.root.join("config/data/resume.txt")
      return unless File.exist?(path)

      File.read(path)
    end

    def score_job(resume)
      client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])

      prompt = <<~PROMPT
      Score how well this job matches this resume from 0–100.

      Resume:
      #{resume}

      Job:
      #{@job.description}

      Return only a number.
      PROMPT

      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [
            { role: "user", content: prompt }
          ]
        }
      )

      response.dig("choices", 0, "message", "content").to_i
    end
  end
end