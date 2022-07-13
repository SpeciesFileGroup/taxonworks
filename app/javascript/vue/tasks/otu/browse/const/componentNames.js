export default () => {
  return {
    NomenclatureHistory: {
      title: 'Timeline',
      status: 'stable'
    },
    Descendants: {
      title: 'Descendants',
      status: 'prototype',
      rankGroup: ['FamilyGroup', 'GenusGroup', 'SpeciesGroup']
    },
    ImageGallery: {
      title: 'Images',
      status: 'prototype',
      rankGroup: ['GenusGroup', 'SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
    },
    CommonNames: {
      title: 'Common names',
      status: 'prototype'
    },
    TypeSection: {
      title: 'Type',
      status: 'prototype',
      rankGroup: ['FamilyGroup', 'GenusGroup']
    },
    TypeSpecimens: {
      title: 'Type specimens',
      status: 'prototype',
      rankGroup: ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
    },
    CollectionObjects: {
      title: 'Specimen records',
      status: 'prototype',
      otu: true,
      rankGroup: ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
    },
    DescriptionComponent: {
      title: 'Description',
      status: 'prototype'
    },
    ContentComponent: {
      title: 'Content',
      status: 'prototype'
    },
    AssertedDistribution: {
      title: 'Asserted distribution',
      status: 'prototype'
    },
    BiologicalAssociations: {
      title: 'Biological associations',
      status: 'prototype'
    },
    AnnotationsComponent: {
      title: 'Annotations',
      status: 'prototype'
    },
    CollectingEvents: {
      title: 'Distribution',
      status: 'prototype'
    }
  }
}
