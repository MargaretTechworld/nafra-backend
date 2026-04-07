class AddRegionToDistricts < ActiveRecord::Migration[7.1]
  def change
    add_reference :districts, :region, null: true, foreign_key: true
  end
end
