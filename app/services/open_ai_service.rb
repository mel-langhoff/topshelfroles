require "net/http"
require "json"

class OpenAiService
  API_URL = URI("https://api.openai.com/v1/chat/completions")

  def chat_completion(messages:)
    http = Net::HTTP.new(API_URL.host, API_URL.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(API_URL)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{ENV["OPENAI_API_KEY"]}"

    request.body = {
      model: "gpt-4.1-mini",
      messages: messages
    }.to_json

    response = http.request(request)
    data = JSON.parse(response.body)

    data.dig("choices", 0, "message", "content")
  end
end