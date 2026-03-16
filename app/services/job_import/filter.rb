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
        not_workday? &&
        ai_relevant?
    end

    private

    attr_reader :job_data, :search_profile

    # Cheap filter first
    def remote_match?
      job_data[:remote] == true
    end

    # Block workday spam
    def not_workday?
      !job_data[:apply_url].to_s.downcase.include?("workday")
    end

    # Keyword filter instead of AI (fast + reliable)
    def ai_relevant?
      text = [
        job_data[:title],
        job_data[:description],
        job_data[:location_text]
      ].join(" ").downcase

      TARGET_TITLE_TERMS.any? { |term| text.include?(term) }
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