require "net/http"
require "json"

module JobSources
  class WorkableService
    COMPANIES = [
      "shopmonkey",
      "sourcegraph",
      "paddle"
    ]

    def fetch_jobs
      jobs = []

      COMPANIES.each do |company|
        url = URI("https://apply.workable.com/api/v3/accounts/#{company}/jobs")

        response = Net::HTTP.get(url)
        data = JSON.parse(response)

        data["results"].each do |job|
          jobs << {
            title: job["title"],
            company_name: company.capitalize,
            location_text: job["location"]["location_str"],
            description: job["description"],
            apply_url: job["url"],
            remote: job["location"]["location_str"].to_s.downcase.include?("remote")
          }
        end
      end

      jobs
    end
  end
end