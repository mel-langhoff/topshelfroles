class CreateSearchProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :search_profiles do |t|
      t.string :name
      t.text :target_titles
      t.text :target_skills
      t.text :keywords
      t.text :negative_keywords
      t.text :excluded_titles
      t.text :excluded_sources
      t.boolean :remote_only
      t.text :allowed_locations
      t.float :minimum_rating
      t.boolean :exclude_workday
      t.boolean :active

      t.timestamps
    end
  end
end
