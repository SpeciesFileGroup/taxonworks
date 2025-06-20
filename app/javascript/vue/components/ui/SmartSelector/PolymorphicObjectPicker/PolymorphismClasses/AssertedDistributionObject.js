import { BiologicalAssociation, Conveyance, Depiction, Observation, Otu } from "@/routes/endpoints"

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
    singular: 'Conveyance',
    plural: 'Conveyances',
    human: 'conveyance',
    display: 'Conveyance',
    snake: 'conveyances',
    endpoint: Conveyance,
    query_key: 'conveyance_id',
    secondary: 'Otu', // Restricts Conveyance object type to Otu
    searchbox_text: 'Search for a conveyance - on OTUs only',
    polymorphic_types_allowed: { polymorphic_types_allowed: ['Otu'] }
  },

  {
    singular: 'Depiction',
    plural: 'Depictions',
    human: 'depiction',
    display: 'Depiction',
    snake: 'depictions',
    endpoint: Depiction,
    query_key: 'depiction_id',
    secondary: 'Otu', // Restricts Depiction object type to Otu
    searchbox_text: 'Search for a depiction - on OTUs only',
    polymorphic_types_allowed: { polymorphic_types_allowed: ['Otu'] }
  },

  {
    singular: 'Observation',
    plural: 'Observations',
    human: 'observation',
    display: 'Observation',
    snake: 'observations',
    endpoint: Observation,
    query_key: 'observation_id',
    secondary: 'Otu', // Restricts Observation object type to Otu
    searchbox_text: 'Search for an observation - on OTUs only',
    polymorphic_types_allowed: { polymorphic_types_allowed: ['Otu'] }
  },
]