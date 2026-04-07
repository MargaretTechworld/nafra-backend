class ChangeSubmissionsDraftIdToNull < ActiveRecord::Migration[7.1]
  def change
    change_column_null :submissions, :draft_id, true
  end
end
