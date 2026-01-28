require "test_helper"

class SubmissionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @admin_user = User.create!(email: 'admin@example.com', password: 'password123', role: 'admin')
    @agency = agencies(:one)
  end

  test "should create valid submission" do
    submission = Submission.new(
      agency: @agency,
      submitted_by: @user,
      submitted_at: Date.today
    )
    assert submission.save, submission.errors.full_messages.to_sentence
  end

  test "should not allow future submitted_at date" do
    submission = Submission.new(
      agency: @agency,
      submitted_by: @user,
      submitted_at: Date.tomorrow
    )
    assert_not submission.save
    assert submission.errors.full_messages.to_sentence.include?("cannot be in the future")
  end

  test "non-admin user cannot submit for different agency" do
    @user.update(agency: @agency)
    other_agency = Agency.create!(
      name: "Other Agency",
      project_name: "Other Project",
      ministry: "Ministry",
      user_id: User.create!(email: 'other@example.com', password: 'password123', role: 'agency').id
    )

    submission = Submission.new(
      agency: other_agency,
      submitted_by: @user,
      submitted_at: Date.today
    )
    assert_not submission.save
  end

  test "admin can submit for any agency" do
    submission = Submission.new(
      agency: @agency,
      submitted_by: @admin_user,
      submitted_at: Date.today
    )
    assert submission.save, submission.errors.full_messages.to_sentence
  end

  test "submission requires agency and submitted_by" do
    submission = Submission.new(submitted_at: Date.today)
    assert_not submission.save
    assert submission.errors[:agency].present?
    assert submission.errors[:submitted_by].present?
  end

  test "submission requires submitted_at" do
    submission = Submission.new(agency: @agency, submitted_by: @user)
    assert_not submission.save
    assert submission.errors[:submitted_at].present?
  end
end
