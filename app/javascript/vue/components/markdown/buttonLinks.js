export default [
  {
    label: 'OTU',
    model: 'otus',
    labelProperty: 'object_label'
  },
  {
    label: 'Source',
    model: 'sources',
    labelProperty: 'cached',
    labelFunction: source => {
      if (source.year && source.cached_author_string) {
        return [source.cached_author_string, source.year].join(', ')
      }

      if (source.cached_author_string) {
        return source.cached_author_string
      }

      return source.cached
    }
  },
  {
    label: 'Taxon name',
    model: 'taxon_names',
    labelProperty: 'object_label'
  }
]
