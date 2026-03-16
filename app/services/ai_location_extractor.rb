class AiLocationExtractor
  def extract(text)
    return "unknown" if text.nil?

    text = text.downcase

    return "colorado" if text.include?("colorado") ||
                         text.include?("denver") ||
                         text.include?("boulder") ||
                         text.include?(", co")

    return "us" if text.include?("united states") ||
                   text.include?("usa") ||
                   text.include?("u.s.")

    return "remote" if text.include?("remote")

    "unknown"
  end
end