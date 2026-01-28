export const TASK_COLLECTING_EVENT_SPATIAL_SUMMARY = {
  label: "Spatial summary",
  link: "/tasks/collecting_events/spatial_summary",
  post: true,
};

export const TASK_COLLECTION_OBJECT_MATCH = {
  label: "Collection object match",
  link: "/tasks/collection_objects/match",
};

export const TASK_COLLECTION_OBJECT_TABLE = {
  label: "Table",
  link: "/tasks/collection_objects/table",
};

export const TASK_COLLECTION_OBJECT_OUTDATED_NAMES = {
  label: "Outdated names (COL match)",
  link: "/tasks/collection_objects/outdated_names/",
};

export const TASK_COLLECTION_OBJECT_SUMMARY = {
  label: "Collection summary",
  link: "/tasks/collection_objects/summary",
};

export const TASK_COLLECTION_OBJECT_MEDIA_EXTENSION = {
  label: "DwC media extension preview",
  link: "/tasks/collection_objects/dwc_media_extension_preview",
};

export const TASK_SOURCE_CITATION_TOTALS = {
  label: "Citation totals",
  link: "/tasks/sources/source_citation_totals/",
};

export const TASK_DOCUMENTS_PACKAGER = {
  label: "Documents packager",
  link: "/tasks/sources/documents_packager",
  saveQuery: true,
};

export const TASK_LOANS_DASHBOARD = {
  label: "Loan dashboard",
  link: "/tasks/loans/dashboard/",
};

export const TASK_TAXON_NAME_STATS = {
  label: "Chronology stats",
  link: "/tasks/taxon_names/stats/",
};

export const TASK_VERBATIM_AUTHOR_YEAR_SOURCE = {
  label: "Verbatim author/year to Source",
  link: "/tasks/sources/verbatim_author_year_source/",
};

export const TASK_CACHED_MAP_ITEM = {
  label: "Cached map items",
  link: "/tasks/cached_maps/report/items_by_otu",
};

export const TASK_FILTER_IMAGES = {
  label: "Filter images",
  link: "/tasks/images/filter",
};

export const TASK_IMAGE_MATRIX = {
  label: "Image matrix",
  link: "/tasks/observation_matrices/image_matrix",
  saveQuery: true,
  parseParams: ({ params }) => ({
    otu_filter: params.otu_id?.join("|"),
  }),
};

export const TASK_BIOLOGICAL_ASSOCIATION_EXTENSION = {
  label: "DwC Extension Preview",
  link: "/tasks/biological_associations/dwc_extension_preview",
};

export const TASK_BIOLOGICAL_ASSOCIATION_TABLE = {
  label: "Simple table",
  link: "/tasks/biological_associations/simple_table",
};

export const TASK_BIOLOGICAL_ASSOCIATION_GLOBI_TABLE = {
  label: "GLOBI preview",
  link: "/tasks/biological_associations/globi_preview",
};

export const TASK_BIOLOGICAL_ASSOCIATION_FAMILY_SUMMARY = {
  label: "Genus by family summary",
  link: "/tasks/biological_associations/family_summary",
};

export const TASK_BIOLOGICAL_ASSOCIATION_GRAPH = {
  label: "Visualize network",
  link: "/tasks/biological_associations/graph",
};

export const TASK_BIOLOGICAL_ASSOCIATION_SUMMARY = {
  label: "Summary (metadata)",
  link: "/tasks/biological_associations/summary",
};

export const TASK_PEOPLE_METADATA = {
  label: "Summary (metadata)",
  link: "/tasks/people/summary",
};

export const TASK_FIELD_SYNCHRONIZE = {
  label: "Field synchronize",
  link: "/tasks/data_attributes/field_synchronize",
  queryParam: true,
  saveQuery: true,
};

export const TASK_MULTI_UPDATE = {
  label: "Multi-update Data attributes",
  link: "/tasks/data_attributes/multi_update",
  queryParam: true,
  saveQuery: true,
};

export const TASK_MONOGRAPH_FACILITATOR = {
  label: "Monograph facilitator",
  link: "/tasks/gis/monograph_facilitator",
  queryParam: true,
  saveQuery: true,
};

export const TASK_DWC_OCCURRENCE_STATUS = {
  label: "DwC Occurrence Status",
  link: "/tasks/dwc_occurrences/status",
};

export const TASK_NEW_CONTAINER = {
  label: "New container",
  link: "/tasks/containers/new_container",
  queryParam: true,
  saveQuery: true,
};

export const TASK_SIMPLEMAPPR = {
  label: "SimpleMappr",
  link: "/tasks/gis/simplemappr",
  post: true,
  queryParam: true,
};

export const TASK_COLLECTING_EVENT_METADATA = {
  label: "Metadata",
  link: "/tasks/collecting_events/metadata",
  post: true,
  queryParam: true,
};

export const TASK_TAXON_NAME_AUTHOR_SUMMARY = {
  label: "Author summary",
  link: "/tasks/taxon_names/author_summary",
  post: true,
  queryParam: true,
};

export const TASK_TAXON_NAME_GENDER = {
  label: "Gender summary",
  link: "/tasks/taxon_names/gender",
  post: true,
  queryParam: true,
};

export const TASK_TAXON_NAME_RECLASSIFIER = {
  label: "Taxon name reclassifier",
  link: "/tasks/nomenclature/reclassifier",
  queryParam: true,
  saveQuery: true,
};

export const TASK_PROJECT_VOCABULARY = {
  label: "Project vocabulary",
  link: "/tasks/metadata/vocabulary/project_vocabulary",
  post: false,
  queryParam: true,
  saveQuery: true,
};

export const TASK_FIELD_OCCURRENCE_MEDIA_EXTENSION = {
  label: "DwC media extension preview",
  link: "/tasks/field_occurrences/dwc_media_extension_preview",
};
