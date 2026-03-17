require "httparty"
require "nokogiri"

module JobImport
  module Scrapers
    class WorkdayScraper
      URL = "https://example.wd5.myworkdayjobs.com/en-US/example/jobs"

      def call
        response = HTTParty.get(URL)
        doc = Nokogiri::HTML(response.body)

        doc.css(".css-1q2dra3").each do |job|
          title = job.css("h3").text
          location = job.css(".css-129m7dg").text

          JobPosting.create!(
            title: title,
            location: location,
            remote: location.downcase.include?("remote")
          )
        end
      end
    end
  end
end