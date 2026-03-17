require "net/http"
require "json"

module JobSources
  class WorkdaySource

    TENANTS = [
  { name: "Coinbase", slug: "coinbase" },
  { name: "Okta", slug: "okta" },
  { name: "Datadog", slug: "datadog" },
  { name: "Tesla", slug: "tesla" },
  { name: "Netflix", slug: "netflix" },
  { name: "Stripe", slug: "stripe" },
  { name: "Salesforce", slug: "salesforce" },
  { name: "HubSpot", slug: "hubspot" },
  { name: "Snowflake", slug: "snowflake" },
  { name: "Twilio", slug: "twilio" },
  { name: "Zendesk", slug: "zendesk" },
  { name: "Atlassian", slug: "atlassian" },
  { name: "PaloAltoNetworks", slug: "paloaltonetworks" },
  { name: "ServiceNow", slug: "servicenow" },
  { name: "Qualtrics", slug: "qualtrics" },
  { name: "Workday", slug: "workday" },
  { name: "Box", slug: "box" },
  { name: "Unity", slug: "unity" },
  { name: "Splunk", slug: "splunk" },
  { name: "Nvidia", slug: "nvidia" }
]

    def fetch_jobs
      jobs = []

      TENANTS.each do |tenant|
        offset = 0
        limit = 20

        loop do
          uri = URI("https://#{tenant[:slug]}.wd5.myworkdayjobs.com/wday/cxs/#{tenant[:slug]}/jobs/jobs")

          request = Net::HTTP::Post.new(uri)
          request["Content-Type"] = "application/json"
          request.body = {
            limit: limit,
            offset: offset
          }.to_json

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          response = http.request(request)
          break unless response.is_a?(Net::HTTPSuccess)

          data = JSON.parse(response.body)

          postings = data["jobPostings"] || []
          break if postings.empty?

          postings.each do |job|
            jobs << {
              title: job["title"],
              company_name: tenant[:name],
              location_text: job["locationsText"],
              description: "",
              apply_url: "https://#{tenant[:slug]}.wd5.myworkdayjobs.com/#{tenant[:slug]}/job/#{job["externalPath"]}",
              remote: job["locationsText"].to_s.downcase.include?("remote")
            }
          end

          offset += limit
        end

      rescue StandardError => e
        Rails.logger.error("Workday failed for #{tenant[:name]}: #{e.message}")
      end

      jobs
    end
  end
end