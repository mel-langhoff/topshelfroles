require "net/http"
require "nokogiri"
require "uri"

module JobSources
  class CareerSiteSource

    CAREER_SITES = [
      "https://vercel.com/careers",
      "https://openai.com/careers",
      "https://notion.so/careers",
      "https://figma.com/careers"
    ]

    def fetch_jobs
      jobs = []

      CAREER_SITES.each do |site|
        html = Net::HTTP.get(URI(site))
        doc = Nokogiri::HTML(html)

        doc.css("a").each do |link|
          href = link["href"]
          next unless href

          if href.include?("job") || href.include?("career") || href.include?("position")
            url = URI.join(site, href).to_s rescue nil
            next unless url

            job = JobImport::JobPageScraper.new(url).call
            jobs << job if job
          end
        end
      end

      jobs
    end

  end
end