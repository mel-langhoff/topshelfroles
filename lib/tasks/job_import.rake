namespace :jobs do
  desc "Import jobs from all sources"
  task import: :environment do
    JobImport::ImportCoordinator.new.call
  end

  desc "Score jobs with AI"
  task score: :environment do
    JobPosting.find_each do |job|
      JobScoring::AiJobScorer.new(job).call
    end
  end

  desc "Import and score jobs"
  task refresh: :environment do
    JobImport::ImportCoordinator.new.call

    JobPosting.find_each do |job|
      JobScoring::AiJobScorer.new(job).call
    end
  end
end