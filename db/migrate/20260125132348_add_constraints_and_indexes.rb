class AddConstraintsAndIndexes < ActiveRecord::Migration[7.1]
  def change
    # Add constraints to submission_items for data integrity
    change_column_null :submission_items, :bags_25kg, false, 0
    change_column_null :submission_items, :bags_50kg, false, 0

    # Add indexes for better query performance on submission_items
    add_index :submission_items, :district_id, if_not_exists: true
    add_index :submission_items, :chiefdom_id, if_not_exists: true
    add_index :submission_items, :fertilizer_id, if_not_exists: true
    add_index :submission_items, :dealer_id, if_not_exists: true
    
    # Composite index for analytics queries
    add_index :submission_items, [:submission_id, :district_id], if_not_exists: true
    add_index :submission_items, [:submission_id, :fertilizer_id], if_not_exists: true
  end
end
