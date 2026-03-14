require "net/http"
require "nokogiri"
require "uri"

module JobSources
  class CareerSiteSource
    CAREER_SITES = [
      "https://stripe.com/jobs",
      "https://vercel.com/careers",
      "https://openai.com/careers",
      "https://notion.so/careers",
      "https://figma.com/careers"
    ]

    def fetch_jobs
      job_urls = []

      CAREER_SITES.each do |site|
        html = Net::HTTP.get(URI(site))
        doc = Nokogiri::HTML(html)

        doc.css("a").each do |link|
          href = link["href"]
          next unless href

          if href.include?("job") || href.include?("career") || href.include?("position")
            url = URI.join(site, href).to_s rescue nil
            job_urls << url if url
          end
        end
      end

      job_urls.uniq.map do |url|
        {
          apply_url: url,
          source_name: "career_site"
        }
      end
    end
  end
end