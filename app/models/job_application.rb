class JobApplication < ApplicationRecord
  belongs_to :job_posting

  validates :status, presence: true
end