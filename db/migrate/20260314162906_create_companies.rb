class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.float :glassdoor_rating
      t.text :notes

      t.timestamps
    end
  end
end
