import {
  ASSERTED_DISTRIBUTION,
  BIOLOGICAL_ASSOCIATION,
  COLLECTING_EVENT,
  COLLECTION_OBJECT,
  EXTRACT,
  IMAGE,
  OTU,
  PEOPLE,
  SOURCE,
  TAXON_NAME,
  DESCRIPTOR,
  OBSERVATION,
  CONTENT
} from 'constants/index.js'

const RouteNames = {
  // FilterAssertedDistribition: '/tasks/asserted_distributions/filter',
  BrowseCollectionObject: '/tasks/collection_objects/browse',
  BrowseNomenclature: '/tasks/nomenclature/browse',
  BrowseOtu: '/tasks/otus/browse',
  ContentEditorTask: '/tasks/content/editor/index',
  DigitizeTask: '/tasks/accessions/comprehensive',
  DwcDashboard: '/tasks/dwc/dashboard',
  DwcImport: '/tasks/dwca_import/index',
  FilterCollectionObjects: '/tasks/collection_objects/filter',
  FilterCollectingEvents: '/tasks/collecting_events/filter',
  ImageMatrix: '/tasks/matrix_image/matrix_image/index',
  InteractiveKeys: '/tasks/observation_matrices/interactive_key',
  ManageBiocurationTask:
    '/tasks/controlled_vocabularies/biocuration/build_collection',
  ManageControlledVocabularyTask: '/tasks/controlled_vocabularies/manage',
  MatchCollectionObject: '/tasks/collection_objects/match',
  MatrixRowCoder: '/tasks/observation_matrices/row_coder/index',
  NewCollectingEvent: '/tasks/collecting_events/new_collecting_event',
  NewExtract: '/tasks/extracts/new_extract',
  NewNamespace: '/tasks/namespaces/new_namespace',
  NewTaxonName: '/tasks/nomenclature/new_taxon_name',
  NewSource: '/tasks/sources/new_source',
  NomenclatureBySource: '/tasks/nomenclature/by_source',
  NomenclatureStats: '/tasks/nomenclature/stats',
  ObservationMatricesDashboard: '/tasks/observation_matrices/dashboard',
  ObservationMatricesHub: '/tasks/observation_matrices/observation_matrix_hub',
  PrintLabel: '/tasks/labels/print_labels',
  TypeMaterial: '/tasks/type_material/edit_type_material'
}

const FILTER_ROUTES = {
  [ASSERTED_DISTRIBUTION]: '/tasks/asserted_distributions/filter',
  [BIOLOGICAL_ASSOCIATION]: '/tasks/biological_associations/filter',
  [COLLECTING_EVENT]: '/tasks/collecting_events/filter',
  [COLLECTION_OBJECT]: '/tasks/collection_objects/filter',
  [EXTRACT]: '/tasks/extracts/filter',
  [IMAGE]: '/tasks/images/filter',
  [OTU]: '/tasks/otus/filter',
  [PEOPLE]: '/tasks/people/filter',
  [SOURCE]: '/tasks/sources/filter',
  [TAXON_NAME]: '/tasks/taxon_names/filter',
  [DESCRIPTOR]: '/tasks/descriptors/filter',
  [OBSERVATION]: '/tasks/observations/filter',
  [CONTENT]: '/tasks/content/filter'
}

export { RouteNames, FILTER_ROUTES }
