FactoryBot.define do
  factory :job_application do
    association :job_posting
    status { "saved" }
    applied_at { nil }
    follow_up_due_at { 7.days.from_now }
    last_contact_at { nil }
    contact_name { "Recruiter Person" }
    contact_email { "recruiter@example.com" }
    notes { "Looks promising." }
    resume_version { "v1" }
    cover_letter_version { "v1" }
    outcome_notes { nil }
  end
end