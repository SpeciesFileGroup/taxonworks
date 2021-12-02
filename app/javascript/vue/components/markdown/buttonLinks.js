export default [
  {
    label: 'OTU',
    model: 'otus',
    link: '/tasks/otus/browse',
    param: 'otu_id',
    propertyLabel: 'object_label'
  },
  {
    label: 'Source',
    model: 'sources',
    link: '/tasks/sources/new_source',
    param: 'source_id',
    propertyLabel: 'cached'
  },
  {
    label: 'Taxon name',
    model: 'taxon_names',
    link: '/tasks/nomenclature/browse',
    param: 'taxon_name_id',
    propertyLabel: 'object_label'
  }
]
