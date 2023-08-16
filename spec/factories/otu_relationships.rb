FactoryBot.define do
  factory :valid_otu_relationship, class: 'OtuRelationship' do
    association :subject_otu, factory: :valid_otu
    type { 'OtuRelationship::Disjoint' }
    association :object_otu, factory: :valid_otu
  end
end
