import { BiologicalAssociation, Depiction, Otu } from "@/routes/endpoints"

export default [
  // Default first.
  {
    singular: 'Otu',
    plural: 'Otus',
    human: 'OTU',
    display: 'Otu',
    snake: 'otus',
    endpoint: Otu,
    query_key: 'otu_id',
    searchbox_text: 'Search for an OTU'
  },

  {
    singular: 'BiologicalAssociation',
    plural: 'BiologicalAssociations',
    human: 'biological association',
    display: 'Biological association',
    snake: 'biological_associations',
    endpoint: BiologicalAssociation,
    query_key: 'biological_association_id',
  },

  {
    singular: 'Depiction',
    plural: 'Depictions',
    human: 'depiction',
    display: 'Depiction',
    snake: 'depictions',
    endpoint: Depiction,
    query_key: 'depiction_id',
    secondary: 'Otu',
    searchbox_text: 'Search for a depiction - on OTUs only',
    polymorphic_types_allowed: { polymorphic_types_allowed: ['Otu'] }
  },

]