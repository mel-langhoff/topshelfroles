require "rails_helper"

RSpec.describe SearchProfile, type: :model do
  describe "associations" do
    it { should have_many(:job_postings).dependent(:nullify) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end
end