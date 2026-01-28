# Serializer for SubmissionItem responses
class SubmissionItemSerializer
  def initialize(submission_item)
    @item = submission_item
  end

  def as_json
    {
      id: @item.id,
      district: {
        id: @item.district.id,
        name: @item.district.name
      },
      chiefdom: {
        id: @item.chiefdom.id,
        name: @item.chiefdom.name
      },
      fertilizer: {
        id: @item.fertilizer.id,
        name: @item.fertilizer.name
      },
      dealer: {
        id: @item.dealer.id,
        name: @item.dealer.name,
        license_number: @item.dealer.license_number
      },
      bags_25kg: @item.bags_25kg,
      bags_50kg: @item.bags_50kg,
      created_at: @item.created_at,
      updated_at: @item.updated_at
    }
  end
end
