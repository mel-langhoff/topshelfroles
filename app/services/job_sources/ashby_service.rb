require "net/http"
require "json"

module JobSources
  class AshbyService
    COMPANIES = [
      "openai",
      "figma",
      "retool"
    ]

    def fetch_jobs
      jobs = []

      COMPANIES.each do |company|
        uri = URI("https://jobs.ashbyhq.com/api/non-user-graphql")

        body = {
          operationName: "JobBoard",
          variables: { organizationHostedJobsPageName: company },
          query: <<~GRAPHQL
            query JobBoard($organizationHostedJobsPageName: String!) {
              jobBoardWithTeams(organizationHostedJobsPageName: $organizationHostedJobsPageName) {
                jobs {
                  title
                  descriptionHtml
                  locationName
                  applyUrl
                }
              }
            }
          GRAPHQL
        }

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
        request.body = body.to_json

        response = http.request(request)
        data = JSON.parse(response.body)

        jobs_data = data.dig("data", "jobBoardWithTeams", "jobs") || []

        jobs_data.each do |job|
          jobs << {
            title: job["title"],
            company_name: company.capitalize,
            location_text: job["locationName"],
            description: job["descriptionHtml"],
            apply_url: job["applyUrl"],
            remote: job["locationName"].to_s.downcase.include?("remote")
          }
        end
      end

      jobs
    end
  end
end 