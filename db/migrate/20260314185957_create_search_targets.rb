class CreateSearchTargets < ActiveRecord::Migration[7.1]
  def change
    create_table :search_targets do |t|
      t.string :name
      t.string :base_url
      t.string :source_type
      t.boolean :active
      t.string :search_mode
      t.text :notes

      t.timestamps
    end
  end
end
