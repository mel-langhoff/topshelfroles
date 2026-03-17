require "net/http"
require "json"

module JobSources
  class LeverSource
    ACCOUNT_NAMES = %w[
  plaid
  rippling
  scaleai
  flexport
  discord
  robinhood
  docker
  amplitude
].freeze

    def fetch_jobs
      ACCOUNT_NAMES.flat_map do |account_name|
        fetch_account_jobs(account_name)
      end
    end

    private

    def fetch_account_jobs(account_name)
      url = URI("https://api.lever.co/v0/postings/#{account_name}?mode=json")
      response = Net::HTTP.get_response(url)

      return [] unless response.is_a?(Net::HTTPSuccess)

      jobs = JSON.parse(response.body)

      jobs.map do |job|
        {
          external_id: job["id"].to_s,
          source_name: "lever",
          company_name: account_name.titleize,
          title: job["text"].to_s.strip,
          location_text: job.dig("categories", "location").to_s.strip,
          remote: remote_job?(job),
          apply_url: job["hostedUrl"].to_s.strip,
          description: job["descriptionPlain"].to_s,
          posted_at: posted_at_for(job)
        }
      end
    rescue JSON::ParserError, StandardError => e
      Rails.logger.error("Lever fetch failed for #{account_name}: #{e.message}")
      []
    end

    def remote_job?(job)
      haystack = [
        job.dig("categories", "location"),
        job["descriptionPlain"]
      ].join(" ").downcase

      haystack.include?("remote") ||
        haystack.include?("united states") ||
        haystack.include?("usa")
    end

    def posted_at_for(job)
      return Time.current if job["createdAt"].blank?

      Time.zone.at(job["createdAt"].to_i / 1000)
    rescue StandardError
      Time.current
    end
  end
end