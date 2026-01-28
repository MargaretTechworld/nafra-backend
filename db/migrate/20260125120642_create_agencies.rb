class CreateAgencies < ActiveRecord::Migration[7.1]
  def change
    create_table :agencies do |t|
      t.string :name, null: false, index: { unique: true }  
      t.string :project_name, null: false
      t.string :ministry, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
