class AddSourceToJobPostings < ActiveRecord::Migration[7.1]
  def change
    add_column :job_postings, :source, :string
  end
end
