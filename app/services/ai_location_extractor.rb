class AiLocationExtractor
  def extract(text)
    return nil if text.nil?

    locations = [
      "United States",
      "USA",
      "U.S.",
      "Colorado",
      "Denver",
      "Boulder",
      "Remote",
      "US"
    ]

    found = locations.find { |loc| text.downcase.include?(loc.downcase) }

    found || "Unknown"
  end
end