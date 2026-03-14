FactoryBot.define do
  factory :search_profile do
    name { "Remote TPM" }
    target_titles { "Technical Program Manager, Technical Project Manager" }
    target_skills { "Ruby, Rails, APIs, SaaS, Agile" }
    keywords { "remote, platform, delivery, technical" }
    negative_keywords { "onsite, principal, staff frontend" }
    excluded_titles { "Sales, Nurse" }
    excluded_sources { "Workday" }
    remote_only { true }
    allowed_locations { "United States, Colorado" }
    minimum_rating { 3.5 }
    exclude_workday { true }
    active { true }
  end
end