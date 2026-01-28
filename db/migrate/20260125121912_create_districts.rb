class CreateDistricts < ActiveRecord::Migration[7.1]
  def change
    create_table :districts do |t|
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
