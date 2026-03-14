require "rails_helper"

RSpec.describe JobImport::Filter do
  let(:search_profile) do
    create(
      :search_profile,
      target_titles: "technical program manager,implementation manager",
      target_skills: "ruby,rails,api",
      keywords: "remote,delivery"
    )
  end

  it "passes for a relevant remote US job" do
    job_data = {
      title: "Technical Program Manager",
      location_text: "Remote, United States",
      description: "Lead API platform delivery.",
      remote: true,
      apply_url: "https://boards.greenhouse.io/job/123"
    }

    result = described_class.new(job_data, search_profile).passes?
    expect(result).to be(true)
  end

  it "fails for a workday URL" do
    job_data = {
      title: "Technical Program Manager",
      location_text: "Remote, United States",
      description: "Lead API platform delivery.",
      remote: true,
      apply_url: "https://company.workday.com/job/123"
    }

    result = described_class.new(job_data, search_profile).passes?
    expect(result).to be(false)
  end

  it "fails for a non-remote job" do
    job_data = {
      title: "Technical Program Manager",
      location_text: "Denver, Colorado",
      description: "Lead API platform delivery.",
      remote: false,
      apply_url: "https://boards.greenhouse.io/job/123"
    }

    result = described_class.new(job_data, search_profile).passes?
    expect(result).to be(false)
  end
end