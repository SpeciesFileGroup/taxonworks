import { PERSON } from '@/constants'
import { RouteNames } from '@/routes/routes'

export default {
  [PERSON]: [
    {
      name: 'Filter Sources (Author)',
      path: RouteNames.FilterSources,
      idParam: 'author_id[]'
    },
    {
      name: 'Filter Sources (Editor)',
      path: RouteNames.FilterSources,
      idParam: 'editor_id[]'
    },
    {
      name: 'Filter taxon names',
      path: RouteNames.FilterNomenclature,
      idParam: 'taxon_name_author_id[]'
    }
  ]
}
