require "openai"
require "json"

module JobScoring
  class JobMatchScorer
    def initialize(job)
      @job = job
    end

    def call
      resume = load_resumes
      unless resume
        Rails.logger.error("Resume files not found")
        return
      end

      result = analyze_job(resume)

      unless result
        Rails.logger.error("AI analysis failed")
        return
      end

      @job.update(
        ai_score: result[:score],
        ai_summary: result[:summary]
      )
    end

    private

    def load_resumes
      path1 = Rails.root.join("config/data/Melissa Langhoff_resume.txt")
      path2 = Rails.root.join("config/data/Melissa Langhoff_CS_resume.txt")

      return nil unless File.exist?(path1) && File.exist?(path2)

      File.read(path1) + "\n\n" + File.read(path2)
    end

def analyze_job(resume)
  client = OpenAI::Client.new

  description = @job.description.to_s[0..2000]

  prompt = <<~PROMPT
  You are a 20 year veteran tech recruiter that works at the top headhunter agency in the nation. Evaluate this resume against this job description. 

  Resume:
  #{resume}

  Job Description:
  #{description}

  Respond ONLY with JSON:

  {
    "score": number from 0-100,
    "summary": "2 paragraph explanation"
  }
  PROMPT

  response = client.chat.completions.create(
    model: "gpt-4o-mini",
    messages: [
      { role: "user", content: prompt }
    ],
    temperature: 0
  )

  text = response.choices[0].message.content

  parse_response(text)
end

    def parse_response(text)
      json_text = text[/\{.*\}/m]
      return nil unless json_text

      data = JSON.parse(json_text)

      {
        score: data["score"].to_i.clamp(0,100),
        summary: data["summary"].to_s
      }
    rescue JSON::ParserError
      Rails.logger.error("JSON parse failed: #{text}")
      nil
    end
  end
end