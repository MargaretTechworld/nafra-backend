class UpdateDealersTable < ActiveRecord::Migration[7.1]
  def change
    change_table :dealers do |t|
      t.string :category
      t.string :category_type
      t.text :head_office_address
      t.string :ceo_name
      t.date :registration_date
      t.date :license_expiry_date
      t.string :licensing_status, default: "Not Licensed"
    end
  end
end
