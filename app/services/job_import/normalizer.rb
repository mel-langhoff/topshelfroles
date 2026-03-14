module JobImport
  class Normalizer
    def initialize(raw_job)
      @raw_job = raw_job
    end

    def call
      return nil if raw_job.blank?

      {
        external_id: raw_job[:external_id].to_s,
        source_name: raw_job[:source_name].to_s.downcase.strip,
        company_name: normalize_text(raw_job[:company_name]),
        title: normalize_text(raw_job[:title]),
        location_text: normalize_text(raw_job[:location_text]),
        remote: !!raw_job[:remote],
        apply_url: raw_job[:apply_url].to_s.strip,
        description: raw_job[:description].to_s.strip,
        posted_at: normalize_time(raw_job[:posted_at])
      }
    end

    private

    attr_reader :raw_job

    def normalize_text(value)
      value.to_s.strip
    end

    def normalize_time(value)
      return value if value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone)
      Time.zone.parse(value.to_s)
    rescue ArgumentError, TypeError
      Time.current
    end
  end
end