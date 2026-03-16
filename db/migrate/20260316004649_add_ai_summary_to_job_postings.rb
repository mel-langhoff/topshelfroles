class AddAiSummaryToJobPostings < ActiveRecord::Migration[7.1]
  def change
    add_column :job_postings, :ai_summary, :text
  end
end
