class CreateSubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :submissions do |t|
      t.references :agency, null: false, foreign_key: true
      t.references :submitted_by, null: false, foreign_key: { to_table: :users }
      t.date :submitted_at

      t.timestamps
    end
  end
end
