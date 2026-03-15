module JobScoring
  class ResumeLoader
    def self.for_job(job)
      title = job.title.to_s.downcase

      if title.include?("CS") || title.include?("Langhoff_resume")
        File.read(Rails.root.join("config/data/Melissa Langhoff_CS_resume.txt"))
      else
        File.read(Rails.root.join("config/data/Melissa Langhoff_resume.txt"))
      end
    end
  end
end