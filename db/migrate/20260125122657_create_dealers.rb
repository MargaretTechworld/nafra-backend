class CreateDealers < ActiveRecord::Migration[7.1]
  def change
    create_table :dealers do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :license_number
      t.string :status, null: false, default: "active"

      t.timestamps
    end
  end
end
