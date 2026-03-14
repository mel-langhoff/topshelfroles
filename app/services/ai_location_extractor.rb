require "openai"

class AiLocationExtractor
  def extract(text)
    return nil if text.nil? || text.empty?

    client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])

    response = client.chat(
      model: "gpt-4o-mini",
      messages: [
        {
          role: "user",
          content: "Extract the job location from this text. Return only the location.\n\n#{text}"
        }
      ]
    )

    response["choices"][0]["message"]["content"]
  end
end