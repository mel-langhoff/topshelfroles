module JobImport
  class Filter
    TARGET_TITLE_TERMS = [
      "technical program manager",
      "technical project manager",
      "program manager",
      "project manager",
      "implementation manager",
      "delivery manager",
      "solutions engineer",
      "customer success engineer",
      "integrations",
      "api",
      "backend",
      "ruby",
      "rails"
    ].freeze

    def initialize(job_data, search_profile = nil)
      @job_data = job_data
      @search_profile = search_profile
    end

    def passes?
      remote_match? &&
        location_match? &&
        not_workday? &&
        title_match?
    end

    private

    attr_reader :job_data, :search_profile

    def remote_match?
      job_data[:remote] == true
    end

    def location_match?
      haystack = "#{job_data[:location_text]} #{job_data[:description]}".downcase

      haystack.include?("united states") ||
        haystack.include?("usa") ||
        haystack.include?("u.s.") ||
        haystack.include?("us-only") ||
        haystack.include?("colorado") ||
        haystack.include?("co")
    end

    def not_workday?
      !job_data[:apply_url].to_s.downcase.include?("workday")
    end

    def title_match?
      title = job_data[:title].to_s.downcase

      profile_terms = search_profile_terms
      terms = (TARGET_TITLE_TERMS + profile_terms).uniq

      terms.any? { |term| title.include?(term.downcase) }
    end

    def search_profile_terms
      return [] unless search_profile

      [
        search_profile.target_titles,
        search_profile.target_skills,
        search_profile.keywords
      ].compact.flat_map { |text| text.split(",") }.map(&:strip)
    end
  end
end