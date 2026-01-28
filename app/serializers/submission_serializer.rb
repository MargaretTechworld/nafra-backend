# Serializer for Submission responses
class SubmissionSerializer
  def initialize(submission)
    @submission = submission
  end

  def as_json
    {
      id: @submission.id,
      agency: {
        id: @submission.agency.id,
        name: @submission.agency.name,
        project_name: @submission.agency.project_name
      },
      submitted_by: {
        id: @submission.submitted_by.id,
        name: @submission.submitted_by.name,
        email: @submission.submitted_by.email
      },
      submitted_at: @submission.submitted_at,
      created_at: @submission.created_at,
      updated_at: @submission.updated_at,
      submission_items: @submission.submission_items.map { |item| SubmissionItemSerializer.new(item).as_json },
      total_bags_25kg: calculate_total_bags_25kg,
      total_bags_50kg: calculate_total_bags_50kg
    }
  end

  private

  def calculate_total_bags_25kg
    @submission.submission_items.sum { |item| item.bags_25kg || 0 }
  end

  def calculate_total_bags_50kg
    @submission.submission_items.sum { |item| item.bags_50kg || 0 }
  end
end
