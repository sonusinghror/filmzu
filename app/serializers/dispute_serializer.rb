class DisputeSerializer < ActiveModel::Serializer
  attributes :id, :dispute_id, :dispute_description, :dispute_date
end
