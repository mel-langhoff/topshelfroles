require "uri"

module JobSources
  class ScrapedSitesSource

    URLS = [
      "https://jobs.ashbyhq.com/Anthropic",
      "https://jobs.ashbyhq.com/Stripe",
      "https://jobs.ashbyhq.com/OpenAI"
    ]

    def fetch_jobs
      URLS.each do |url|
        JobImport::JobPageScraper.new(url).call
      end

      []
    end

  end
end