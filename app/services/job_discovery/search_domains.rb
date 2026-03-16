module JobDiscovery
  class SearchDomains
    def self.list
      [
        # Major job boards
        "linkedin.com",
        "indeed.com",
        "wellfound.com",      # formerly AngelList
        "ycombinator.com",

        # ATS platforms (tons of companies use these)
        "greenhouse.io",
        "lever.co",
        "ashbyhq.com",
        "workable.com",
        "jobs.smartrecruiters.com",
        "boards.greenhouse.io",
        "jobs.lever.co",
        "apply.workable.com",

        # Enterprise ATS
        "myworkdayjobs.com",
        "jobs.workday.com",
        "icims.com",
        "jobs.icims.com",
        "successfactors.com",
        "oraclecloud.com",

        # Startup-heavy boards
        "otta.com",
        "jobs.ashbyhq.com",
        "railsdevs.com",
        "hnhiring.com",

        # Tech company careers pages
        "careers.google.com",
        "jobs.netflix.com",
        "stripe.com/jobs",
        "openai.com/careers",
        "shopify.com/careers"
      ]
    end
  end
end