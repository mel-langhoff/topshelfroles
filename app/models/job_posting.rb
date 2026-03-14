class JobPosting < ApplicationRecord
  belongs_to :company
  belongs_to :search_profile
  has_one :job_application, dependent: :destroy

  validates :title, presence: true
  validates :apply_url, presence: true, uniqueness: true

  scope :active, -> { where(excluded: [false, nil]) }
  scope :remote_only, -> { where(remote: true) }
  scope :recent, -> { where("posted_at >= ?", 14.days.ago) }
  scope :ordered_by_score, -> { order(ai_score: :desc, posted_at: :desc) }

  def workday?
    apply_url.to_s.downcase.include?("workday")
  end
end