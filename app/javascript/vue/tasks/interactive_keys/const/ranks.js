import { RouteNames } from 'routes/routes'

export default {
  otu: {
    label: 'object_tag',
    link: (id) => `${RouteNames.BrowseOtu}?otu_id=${id}`
  },
  subspecies: {
    label: 'object_label',
    link: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
  },
  species: {
    label: 'object_label',
    link: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
  },
  subgenus: {
    label: 'object_label',
    link: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
  },
  genus: {
    label: 'object_label',
    link: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
  },
  subtribe: {
    label: 'object_label',
    link: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
  },
  tribe: {
    label: 'object_label',
    link: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
  },
  subfamily: {
    label: 'object_label',
    link: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
  },
  family: {
    label: 'object_label',
    link: (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
  }
}
