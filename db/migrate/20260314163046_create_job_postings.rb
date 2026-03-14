class CreateJobPostings < ActiveRecord::Migration[7.1]
  def change
    create_table :job_postings do |t|
      t.references :company, null: false, foreign_key: true
      t.references :search_profile, null: false, foreign_key: true
      t.string :title
      t.boolean :remote
      t.string :apply_url
      t.text :description
      t.datetime :posted_at
      t.datetime :scraped_at
      t.string :status
      t.integer :ai_score
      t.text :ai_reason
      t.integer :friction_score
      t.boolean :excluded
      t.string :excluded_reason

      t.timestamps
    end
  end
end
