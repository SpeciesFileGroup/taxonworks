# Canonical list of model class names that can be unified via the Unify task.
#
# Served as JSON by GET /unify/types and consumed by the Unify task on load.
#
# !! WARNING !!
# When adding a class here you MUST also add a corresponding entry to TYPE_LINKS
# in app/javascript/vue/tasks/unify/objects/constants/types.js or the model will
# cause a runtime error when selected in the Unify task UI.

UNIFIABLE_MODELS = [
  'AssertedDistribution',
  'BiologicalAssociation',
  'BiologicalAssociationsGraph',
  'CharacterState',
  'CollectingEvent',
  'CollectionObject',
  'Container',
  # 'Content',
  'ControlledVocabularyTerm',
  # 'Depiction',
  'Descriptor',
  'Extract',
  'FieldOccurrence',
  'Georeference',
  'Image',
  'Loan',
  'Observation',
  'ObservationMatrix',
  'Otu',
  # 'Person', # uses a separate merge_with/hard_merge path, not Shared::Unify
  'Repository',
  'Serial',
  'Sound',
  'Source',
  'TaxonName',
  'Topic',
  'TypeMaterial',
].freeze
