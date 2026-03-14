SearchProfile.find_or_create_by!(name: "Remote TPM") do |profile|
  profile.target_titles = "technical program manager,technical project manager,implementation manager,solutions engineer"
  profile.target_skills = "ruby,rails,api,saas,agile,integrations"
  profile.keywords = "remote,technical,platform,delivery"
  profile.negative_keywords = "onsite,warehouse,nurse"
  profile.excluded_titles = "sales associate,office manager"
  profile.excluded_sources = "workday"
  profile.remote_only = true
  profile.allowed_locations = "United States,Colorado"
  profile.minimum_rating = 3.5
  profile.exclude_workday = true
  profile.active = true
end