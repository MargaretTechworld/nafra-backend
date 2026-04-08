class RemoveTownshipsFromSystem < ActiveRecord::Migration[7.1]
  def change
    # Remove foreign key and column from outlets first
    remove_foreign_key :outlets, :townships if foreign_key_exists?(:outlets, :townships)
    remove_column :outlets, :township_id, :bigint if column_exists?(:outlets, :township_id)

    # Drop the townships table
    drop_table :townships if table_exists?(:townships)
  end
end
