FactoryBot.define do
  factory :descriptor_gene, class: 'Descriptor::Gene', traits: [:housekeeping] do
    factory :valid_descriptor_gene do
      name { Faker::Lorem.unique.word }
      type { 'Descriptor::Gene' }
    end
  end
end

