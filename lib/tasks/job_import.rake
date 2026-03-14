namespace :jobs do
  desc "Import jobs from configured sources"
  task import: :environment do
    JobImport::ImportCoordinator.new.call
    puts "Job import complete. Total jobs: #{JobPosting.count}"
  end
end