class AddDraftToSubmissions < ActiveRecord::Migration[7.1]
  def change
    add_reference :submissions, :draft, foreign_key: true
  end
end
