require "net/http"
require "json"
require "uri"

module JobDiscovery
  class SearchBot
    SEARCH_ENDPOINT = "https://api.duckduckgo.com/?q="

    def run
      queries = QueryBuilder.build

      queries.each do |query|
        search(query)
      end
    end

    private

    def search(query)
      url = URI("#{SEARCH_ENDPOINT}#{URI.encode_www_form_component(query)}&format=json")

      response = Net::HTTP.get_response(url)
      return unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)

      extract_links(data)
    end

    def extract_links(data)
      (data["RelatedTopics"] || []).each do |topic|
        next unless topic["FirstURL"]

        process_job_url(topic["FirstURL"])
      end
    end

    def process_job_url(url)
      Rails.logger.info("Discovered job URL: #{url}")

      JobImport::JobPageScraper.new(url).call
    end
  end
end