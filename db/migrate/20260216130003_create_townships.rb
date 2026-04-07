class CreateTownships < ActiveRecord::Migration[7.1]
  def change
    create_table :townships do |t|
      t.string :name, null: false
      t.references :chiefdom, null: false, foreign_key: true
      t.timestamps
    end
    add_index :townships, [:name, :chiefdom_id], unique: true
  end
end
