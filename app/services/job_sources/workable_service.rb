require "net/http"
require "json"

module JobSources
  class WorkableService
    COMPANIES = [
      "shopmonkey",
      "sourcegraph",
      "paddle"
    ].freeze

    def fetch_jobs
      jobs = []

      COMPANIES.each do |company|
        url = URI("https://apply.workable.com/api/v3/accounts/#{company}/jobs")

        response = Net::HTTP.get_response(url)

        unless response.is_a?(Net::HTTPSuccess)
          Rails.logger.error("Workable fetch failed for #{company}: #{response.code}")
          next
        end

        data = JSON.parse(response.body)

        (data["results"] || []).each do |job|
          jobs << {
            title: job["title"],
            company_name: company.capitalize,
            location_text: job.dig("location", "location_str"),
            description: job["description"],
            apply_url: job["url"],
            remote: job.dig("location", "location_str").to_s.downcase.include?("remote")
          }
        end
      rescue JSON::ParserError => e
        Rails.logger.error("Workable parse error for #{company}: #{e.message}")
        next
      end

      jobs
    end
  end
end