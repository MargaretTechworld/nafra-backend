class CreateSubmissionItems < ActiveRecord::Migration[7.1]
  def change
    create_table :submission_items do |t|
      t.references :submission, null: false, foreign_key: true
      t.references :district, null: false, foreign_key: true
      t.references :chiefdom, null: false, foreign_key: true
      t.references :fertilizer, null: false, foreign_key: true
      t.references :dealer, null: false, foreign_key: true
      t.integer :bags_25kg
      t.integer :bags_50kg

      t.timestamps
    end
  end
end
