require "net/http"
require "json"

module JobSources
  class GreenhouseSource
    BOARD_TOKENS = %w[
      stripe
      figma
      notion
    ].freeze

    def fetch_jobs
      BOARD_TOKENS.flat_map do |board_token|
        fetch_board_jobs(board_token)
      end
    end

    private

    def fetch_board_jobs(board_token)
      url = URI("https://boards-api.greenhouse.io/v1/boards/#{board_token}/jobs?content=true")
      response = Net::HTTP.get_response(url)

      return [] unless response.is_a?(Net::HTTPSuccess)

      body = JSON.parse(response.body)
      jobs = body["jobs"] || []

      jobs.map do |job|
        {
          external_id: job["id"].to_s,
          source_name: "greenhouse",
          company_name: board_token.titleize,
          title: job["title"],
          location_text: job.dig("location", "name"),
          remote: remote_job?(job),
          apply_url: job["absolute_url"],
          description: extract_content(job),
          posted_at: Time.current
        }
      end
    rescue JSON::ParserError, StandardError => e
      Rails.logger.error("Greenhouse fetch failed for #{board_token}: #{e.message}")
      []
    end

    def remote_job?(job)
      location = job.dig("location", "name").to_s.downcase
      content = extract_content(job).downcase

      location.include?("remote") ||
        content.include?("remote") ||
        content.include?("united states") ||
        content.include?("usa")
    end

    def extract_content(job)
      metadata = job["content"].to_s
      job["content"].present? ? metadata : ""
    end
  end
end