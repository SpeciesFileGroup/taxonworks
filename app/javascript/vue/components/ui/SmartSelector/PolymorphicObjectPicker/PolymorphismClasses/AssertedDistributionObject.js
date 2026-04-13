import {
  BiologicalAssociation,
  BiologicalAssociationsGraph,
  Conveyance,
  Depiction,
  Observation,
  Otu
} from '@/routes/endpoints'

const AssertedDistributionObject = [
  // Default first.
  {
    singular: 'Otu',
    plural: 'Otus',
    human: 'OTU',
    display: 'OTU',
    snake: 'otus',
    endpoint: Otu,
    query_key: 'otu_id',
    searchbox_text: 'Search for an OTU',
    smartSelector: {
      props: {
        otuPicker: true
      }
    }
  },

  {
    singular: 'BiologicalAssociation',
    plural: 'BiologicalAssociations',
    human: 'biological association',
    display: 'Biological association',
    snake: 'biological_associations',
    endpoint: BiologicalAssociation,
    query_key: 'biological_association_id'
  },

  {
    singular: 'BiologicalAssociationsGraph',
    plural: 'BiologicalAssociationsGraphs',
    human: 'biological associations graph',
    display: 'Biological associations graph',
    snake: 'biological_associations_graphs',
    endpoint: BiologicalAssociationsGraph,
    query_key: 'biological_associations_graph_id'
  },

  {
    singular: 'Conveyance',
    plural: 'Conveyances',
    human: 'conveyance',
    display: 'Conveyance on OTU',
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
    display: 'Depiction on OTU',
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
    display: 'Observation on OTU',
    snake: 'observations',
    endpoint: Observation,
    query_key: 'observation_id',
    secondary: 'Otu', // Restricts Observation object type to Otu
    searchbox_text: 'Search for an observation - on OTUs only',
    polymorphic_types_allowed: { polymorphic_types_allowed: ['Otu'] }
  }
]

const ASSERTED_DISTRIBUTION_OBJECT_ENDPOINT_HASH =
  AssertedDistributionObject.reduce((acc, value) => {
    acc[value.singular] = value.endpoint
    return acc
  }, {})

export default AssertedDistributionObject
export { ASSERTED_DISTRIBUTION_OBJECT_ENDPOINT_HASH }
