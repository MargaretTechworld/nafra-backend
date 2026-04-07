class CreateContactPeople < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_people do |t|
      t.references :dealer, null: false, foreign_key: true
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.string :role
      t.boolean :is_primary, default: false
      t.timestamps
    end
  end
end
