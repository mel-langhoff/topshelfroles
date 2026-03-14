module JobScoring
  class JobMatchScorer
    def initialize(job)
      @job = job
    end

    def call
      score = 0

      score += title_score
      score += remote_score
      score += keyword_score
      score += location_score
      score -= workday_penalty

      job.update!(ai_score: score)

      score
    end

    private

    attr_reader :job

    def title_score
      return 30 if job.title.to_s.downcase.include?("technical program manager")
      return 20 if job.title.to_s.downcase.include?("program manager")

      0
    end

    def remote_score
      job.remote ? 20 : 0
    end

    def keyword_score
      text = "#{job.title} #{job.description}".downcase

      keywords = [
        "api",
        "ruby",
        "rails",
        "platform",
        "backend",
        "distributed systems"
      ]

      keywords.count { |k| text.include?(k) } * 5
    end

    def location_score
      return 10 if job.description.to_s.downcase.include?("united states")
      return 5 if job.description.to_s.downcase.include?("remote")

      0
    end

    def workday_penalty
      job.apply_url.to_s.include?("workday") ? 15 : 0
    end
  end
end