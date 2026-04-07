class CreateDrafts < ActiveRecord::Migration[7.1]
  def change
    create_table :drafts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :data
      t.string :status
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
