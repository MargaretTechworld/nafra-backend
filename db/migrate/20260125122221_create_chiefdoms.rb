class CreateChiefdoms < ActiveRecord::Migration[7.1]
  def change
    create_table :chiefdoms do |t|
      t.string :name, null: false, index: { unique: true }
      t.references :district, null: false, foreign_key: true

      t.timestamps
    end
  end
end
