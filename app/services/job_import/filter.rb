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

    # AI decides if job is relevant
    # def ai_relevant?
    #   resume_text = load_resumes

    #   response = OpenAiService.new.chat_completion(
    #     messages: [
    #       {
    #         role: "system",
    #         content: "You evaluate whether a job is relevant for a US-based technical program manager, technical project manager, customer success professional, or backend developer."
    #       },
    #       {
    #         role: "user",
    #         content: <<~PROMPT
    #           Job title: #{job_data[:title]}
    #           Location: #{job_data[:location_text]}
    #           Description: #{job_data[:description]}

    #           Determine if this job meets BOTH criteria:

    #           1) Remote in the United States or located in Colorado
    #           2) Relevant to technical program management, technical project management, backend engineering, APIs, or Ruby/Rails and fits these resumes:

    #           #{resume_text}

    #           Reply ONLY with YES or NO.
    #         PROMPT
    #       }
    #     ]
    #   )

    #   response.to_s.downcase.include?("yes")
    # end

    # def load_resumes
    #   resume1 = File.read(Rails.root.join("config", "data", "Melissa Langhoff_resume.txt"))
    #   resume2 = File.read(Rails.root.join("config", "data", "Melissa Langhoff_CS_resume.txt"))

    #   "#{resume1}\n\n#{resume2}"
    # end

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