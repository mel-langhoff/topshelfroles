class CreateJobApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :job_applications do |t|
      t.references :job_posting, null: false, foreign_key: true
      t.string :status
      t.datetime :applied_at
      t.datetime :follow_up_due_at
      t.datetime :last_contact_at
      t.string :contact_name
      t.string :contact_email
      t.text :notes
      t.string :resume_version
      t.string :cover_letter_version
      t.text :outcome_notes

      t.timestamps
    end
  end
end
