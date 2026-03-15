require "openai"
require "json"

class AiLocationExtractor
  def initialize
    @client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
  end

  def extract(text)
    prompt = <<~PROMPT
      Extract the job location from this job posting.

      Return JSON only.

      Example:
      {
        "location": "Denver, CO",
        "remote": false
      }

      Job Posting:
      #{text[0..3000]}
    PROMPT

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "You extract structured data from job postings." },
          { role: "user", content: prompt }
        ]
      }
    )

    JSON.parse(response.dig("choices", 0, "message", "content"))
  end
end