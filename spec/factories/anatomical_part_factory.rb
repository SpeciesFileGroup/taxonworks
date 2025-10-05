# # Usage:
# # simplest: builds specimen + TD + origin relationship automatically
# ap = create(:valid_anatomical_part)

# # under an existing specimen
# specimen = create(:valid_specimen)
# create(:valid_taxon_determination, taxon_determination_object: specimen)
# ap = create(:valid_anatomical_part, ancestor: specimen)

# # force which OTU is accepted on the ancestor that gets built
# otu = create(:valid_otu)
# ap  = create(:valid_anatomical_part, taxon_determinatin_otu: otu)

# # make 3 parts under the same specimen
# specimen = create(:valid_specimen)
# create_list(:valid_anatomical_part, 3, :under_specimen, ancestor: specimen)

FactoryBot.define do
  factory :anatomical_part, traits: [:housekeeping] do
    sequence(:name) { |n| "An anatomical part #{n}" }

    transient do
      # Parent at the top of the chain (CollectionObject/Specimen, FieldOccurrence, or OTU).
      ancestor { nil }
      # If provided, make this the accepted OTU on the ancestor (position 1).
      taxon_determination_otu { nil }
    end

    factory :valid_anatomical_part do
      after(:build) do |anatomical_part, evaluator|
        top = evaluator.ancestor || FactoryBot.create(:valid_specimen)

        # If the ancestor is a CO or FO, ensure it has an accepted TD.
        # If an explicit OTU was provided, make it the accepted determination.
        unless top.is_a?(Otu)
          if evaluator.taxon_determination_otu
            taxon_determination = FactoryBot.create(
              :valid_taxon_determination,
              otu: evaluator.taxon_determination_otu,
              taxon_determination_object: top
            )
            taxon_determination.insert_at(1) if taxon_determination.respond_to?(:insert_at) # acts_as_list safety
          elsif top.respond_to?(:taxon_determinations) && top.taxon_determinations.blank?
            FactoryBot.create(
              :valid_taxon_determination,
              otu: FactoryBot.create(:valid_otu),
              taxon_determination_object: top
            )
          end
        end

        anatomical_part.inbound_origin_relationship_attributes = { old_object: top }
      end
    end

    # Convenience: explicitly place the AnatomicalPart under a specimen, field occurrence, or OTU.
    trait :under_specimen do
      transient do
        ancestor { FactoryBot.create(:valid_specimen) }
      end
    end

    trait :under_field_occurrence do
      transient do
        ancestor { FactoryBot.create(:valid_field_occurrence) }
      end
    end

    trait :under_otu do
      transient do
        ancestor { FactoryBot.create(:valid_otu) }
      end
    end

    trait :under_anatomical_part do
      transient do
        ancestor { FactoryBot.create(:valid_anatomical_part) }
      end
    end
  end
end

