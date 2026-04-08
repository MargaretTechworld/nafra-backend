class SubmissionsService
  def self.create_with_items(agency, user, items_params, submitted_at = nil)
    errors = []
    submission = nil

    Submission.transaction do
      submission = Submission.new(
        agency: agency,
        submitted_by: user,
        submitted_at: submitted_at || Date.today
      )

      unless submission.save
        errors = submission.errors.full_messages
        raise ActiveRecord::Rollback
      end

      items_params.each do |item_param|
        item = submission.submission_items.build(
          district_id: item_param[:district_id],
          chiefdom_id: item_param[:chiefdom_id],
          fertilizer_id: item_param[:fertilizer_id],
          dealer_id: item_param[:dealer_id],
          bags_25kg: item_param[:bags_25kg] || 0,
          bags_50kg: item_param[:bags_50kg] || 0
        )
      end

      unless submission.submission_items.all?(&:valid?)
        errors = submission.submission_items.flat_map { |i| i.errors.full_messages }.uniq
        raise ActiveRecord::Rollback
      end

      submission.submission_items.each(&:save!)
    end

    if errors.any?
      { success: false, errors: errors }
    else
      { success: true, submission: submission }
    end
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end
end
