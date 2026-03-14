module JobSources
  class GreenhouseSource
    def fetch_jobs
      [
        {
          external_id: "gh-001",
          source_name: "greenhouse",
          company_name: "Stripe",
          title: "Technical Program Manager",
          location_text: "Remote, United States",
          remote: true,
          apply_url: "https://boards.greenhouse.io/example/jobs/gh-001",
          description: "Lead API and SaaS delivery across technical teams.",
          posted_at: Time.current
        },
        {
          external_id: "gh-002",
          source_name: "greenhouse",
          company_name: "LameCorp",
          title: "Office Manager",
          location_text: "Denver, Colorado",
          remote: false,
          apply_url: "https://boards.greenhouse.io/example/jobs/gh-002",
          description: "Definitely not your thing.",
          posted_at: Time.current
        }
      ]
    end
  end
end