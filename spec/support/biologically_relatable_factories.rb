# Maps each biologically-relatable base class name to a proc that creates an
# instance with a resolvable OTU. The proc receives an Otu that will be used
# where the factory needs an explicit one.
#
# Keep this in sync with the self-validating spec in
# spec/models/concerns/shared/biological_associations_spec.rb
BIOLOGICALLY_RELATABLE_FACTORIES = {
  'Otu' => ->(otu) { otu },
  'CollectionObject' => lambda { |otu|
    s = FactoryBot.create(:valid_specimen)
    FactoryBot.create(:valid_taxon_determination, taxon_determination_object: s, otu:)
    s
  },
  'FieldOccurrence' => ->(otu) { fo = FactoryBot.create(:valid_field_occurrence); fo.taxon_determinations.first.update!(otu:); fo },
  'AnatomicalPart'  => ->(otu) { FactoryBot.create(:valid_anatomical_part, taxon_determination_otu: otu) }
}.freeze
