require "net/http"
require "nokogiri"

module JobImport
  class JobPageScraper
    def initialize(url)
      @url = url
    end

    def call
      html = fetch_page
      return unless html

      parse_job(html)
    end

    private

    attr_reader :url

    def fetch_page
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      return unless response.is_a?(Net::HTTPSuccess)

      response.body
    rescue
      nil
    end

    def parse_job(html)
      doc = Nokogiri::HTML(html)

      title = doc.at("title")&.text.to_s.strip
      body_text = doc.text.to_s[0..20000]

      location_text = AiLocationExtractor.new.extract(body_text)

      raw_job = {
        source_name: "crawler",
        company_name: extract_company,
        title: title,
        location_text: location_text,
        apply_url: url,
        description: body_text,
        posted_at: Time.current
      }

      normalized = JobImport::Normalizer.new(raw_job).call
      return unless normalized

      company = Company.find_or_create_by!(name: normalized[:company_name])

      job = JobPosting.find_or_initialize_by(apply_url: normalized[:apply_url])

      job.company = company
      job.search_profile ||= SearchProfile.first
      job.title = normalized[:title]
      job.remote = normalized[:remote]
      job.description = normalized[:description]
      job.posted_at = normalized[:posted_at]
      job.scraped_at = Time.current
      job.status ||= "new"
      job.ai_score ||= 0
      job.friction_score ||= 0
      job.excluded = false if job.excluded.nil?

      job.save!
    end

    def extract_company
      host = URI(url).host
      host.sub("www.", "").split(".").first.capitalize
    end
  end
end