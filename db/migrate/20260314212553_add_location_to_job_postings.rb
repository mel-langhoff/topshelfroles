class AddLocationToJobPostings < ActiveRecord::Migration[7.1]
  def change
    add_column :job_postings, :location, :string
  end
end
