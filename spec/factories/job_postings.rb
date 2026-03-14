FactoryBot.define do
  factory :job_posting do
    association :company
    association :search_profile

    title { "Technical Program Manager" }
    remote { true }
    apply_url { "https://example.com/jobs/#{SecureRandom.hex(4)}" }
    description { "Lead API delivery and cross-functional SaaS projects." }
    posted_at { 1.day.ago }
    scraped_at { Time.current }
    status { "new" }
    ai_score { 85 }
    ai_reason { "Strong match for PM + API + SaaS background." }
    friction_score { 10 }
    excluded { false }
    excluded_reason { nil }
  end
end