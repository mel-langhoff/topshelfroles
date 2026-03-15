require "uri"

module JobSources
  class ScrapedSitesSource

    URLS = [
      "https://jobs.ashbyhq.com/Anthropic",
      "https://jobs.ashbyhq.com/Stripe",
      "https://jobs.ashbyhq.com/OpenAI"
    ]

    def fetch_jobs
      URLS.map do |url|
        {
          apply_url: url,
          source_name: "scraped_site"
        }
      end
    end

  end
end