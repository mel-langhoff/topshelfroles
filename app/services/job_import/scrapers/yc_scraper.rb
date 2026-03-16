require "httparty"

module JobImport
  module Scrapers
    class YcScraper
      def call
        url = "https://www.ycombinator.com/jobs/api/jobs"

        response = HTTParty.get(url)
        jobs = JSON.parse(response.body)["jobs"]

        jobs.each do |job|
          create_job(job)
        end
      end

      private

      def create_job(job)
        JobPosting.find_or_create_by(apply_url: job["apply_url"]) do |posting|
          posting.title = job["title"]
          posting.location = job["location"]
          posting.description = job["description"]
          posting.posted_at = job["created_at"]
          posting.remote = job["location"].to_s.downcase.include?("remote")
        end
      end
    end
  end
end