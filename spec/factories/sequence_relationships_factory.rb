FactoryGirl.define do
  factory :sequence_relationship, traits: [:housekeeping] do
    factory :valid_sequence_relationship do
      association :subject_sequence, factory: :valid_sequence
      type SequenceRelationship::ReversePrimer
      association :object_sequence, factory: :valid_sequence
    end
  end
end

# FactoryGirl.define do
#   factory :sequence_relationship, traits: [:housekeeping] do
#     factory :valid_sequence_relationship do
#       subject_sequence_id {FactoryGirl.create(:valid_sequence).id}
#       type "ReversePrimer"
#       object_sequence_id {FactoryGirl.create(:valid_sequence).id}
#     end
#   end
# end
