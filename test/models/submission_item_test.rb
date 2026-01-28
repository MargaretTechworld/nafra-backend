require "test_helper"

class SubmissionItemTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @agency = agencies(:one)
    @submission = Submission.create!(
      agency: @agency,
      submitted_by: @user,
      submitted_at: Date.today
    )
    @district = districts(:one)
    @chiefdom = chiefdoms(:one)
    @fertilizer = fertilizers(:one)
    @dealer = dealers(:one)
  end

  test "should create valid submission item" do
    item = SubmissionItem.new(
      submission: @submission,
      district: @district,
      chiefdom: @chiefdom,
      fertilizer: @fertilizer,
      dealer: @dealer,
      bags_25kg: 10,
      bags_50kg: 5
    )
    assert item.save, item.errors.full_messages.to_sentence
  end

  test "at least one bag size must be provided" do
    item = SubmissionItem.new(
      submission: @submission,
      district: @district,
      chiefdom: @chiefdom,
      fertilizer: @fertilizer,
      dealer: @dealer,
      bags_25kg: 0,
      bags_50kg: 0
    )
    assert_not item.save
    assert item.errors[:base].present?
  end

  test "bags must not be negative" do
    item = SubmissionItem.new(
      submission: @submission,
      district: @district,
      chiefdom: @chiefdom,
      fertilizer: @fertilizer,
      dealer: @dealer,
      bags_25kg: -5,
      bags_50kg: 10
    )
    assert_not item.save
  end

  test "submission item requires all associations" do
    item = SubmissionItem.new(bags_25kg: 10, bags_50kg: 5)
    assert_not item.save
    assert item.errors[:submission].present?
    assert item.errors[:district].present?
    assert item.errors[:chiefdom].present?
    assert item.errors[:fertilizer].present?
    assert item.errors[:dealer].present?
  end
end
