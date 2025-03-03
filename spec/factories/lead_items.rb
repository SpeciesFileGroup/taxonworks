FactoryBot.define do
  factory :lead_item do
    lead_id { 1 }
    otu_id { 1 }
    project { nil }
    created_by_id { 1 }
    updated_by_id { 1 }
    position { 1 }
  end
end
