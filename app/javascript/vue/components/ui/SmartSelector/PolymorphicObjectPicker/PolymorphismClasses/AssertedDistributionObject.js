import { BiologicalAssociation, Otu } from "@/routes/endpoints"

export default [
  // Default first.
  {
    singular: 'Otu',
    plural: 'Otus',
    human: 'otu',
    display: 'Otu',
    snake: 'otus',
    endpoint: Otu
  },

  {
    singular: 'BiologicalAssociation',
    plural: 'BiologicalAssociations',
    human: 'biological association',
    display: 'Biological association',
    snake: 'biological_associations',
    endpoint: BiologicalAssociation
  },

]