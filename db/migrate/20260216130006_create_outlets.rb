class CreateOutlets < ActiveRecord::Migration[7.1]
  def change
    create_table :outlets do |t|
      t.references :dealer, null: false, foreign_key: true
      t.text :address, null: false
      t.references :region, null: false, foreign_key: true
      t.references :district, null: false, foreign_key: true
      t.references :chiefdom, null: false, foreign_key: true
      t.references :township, null: false, foreign_key: true
      t.timestamps
    end
  end
end
