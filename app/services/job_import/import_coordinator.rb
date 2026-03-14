module JobImport
  class ImportCoordinator
    def initialize(sources: default_sources, search_profile: nil)
      @sources = sources
      @search_profile = search_profile || SearchProfile.first
    end

    def call
      @sources.each do |source|
        import_source(source)
      end
    end

    private

    attr_reader :sources, :search_profile

    def default_sources
      [
        JobSources::GreenhouseSource.new
      ]
    end

    def import_source(source)
      results = source.fetch_jobs

      results.each do |raw_job|
        normalized_job = JobImport::Normalizer.new(raw_job).call
        next unless normalized_job

        next unless JobImport::Filter.new(normalized_job, search_profile).passes?

        company = Company.find_or_create_by!(name: normalized_job[:company_name])

        JobPosting.find_or_initialize_by(apply_url: normalized_job[:apply_url]).tap do |job|
          job.company = company
          job.search_profile = search_profile
          job.title = normalized_job[:title]
          job.remote = normalized_job[:remote]
          job.apply_url = normalized_job[:apply_url]
          job.description = normalized_job[:description]
          job.posted_at = normalized_job[:posted_at]
          job.scraped_at = Time.current
          job.status ||= "new"
          job.ai_score ||= 0
          job.friction_score ||= 0
          job.excluded = false if job.excluded.nil?
          job.save!
        end
      end
    end
  end
end