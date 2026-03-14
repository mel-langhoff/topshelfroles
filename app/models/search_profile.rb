class SearchProfile < ApplicationRecord
  has_many :job_postings, dependent: :nullify

  validates :name, presence: true
end