import PanelTimeline from '../components/Panel/PanelTimeline/PanelTimeline.vue'
import PanelAssertedDistribution from '../components/Panel/PanelAssertedDistribution/PanelAssertedDistribution.vue'
import PanelDistribution from '../components/Panel/PanelDistribution/PanelDistribution.vue'
import PanelDepictions from '../components/Panel/PanelDepictions/PanelDepictions.vue'
import PanelDescendants from '../components/Panel/PanelDescendants/PanelDescendants.vue'
import PanelCommonNames from '../components/Panel/PanelCommonNames/PanelCommonNames.vue'
import PanelConveyance from '../components/Panel/PanelConveyance/PanelConveyance.vue'
import PanelDescription from '../components/Panel/PanelDescription/PanelDescription.vue'
import PanelContent from '../components/Panel/PanelContent/PanelContent.vue'
import PanelBiologicalAssociations from '../components/Panel/PanelBiologicalAssociations/PanelBiologicalAssociations.vue'
import PanelAnnotations from '../components/Panel/PanelAnnotations/PanelAnnotations.vue'
import PanelType from '../components/Panel/PanelType/PanelType.vue'
import PanelTypeSpecimens from '../components/Panel/PanelTypeSpecimens/PanelTypeSpecimens.vue'
import PanelCollectionObjects from '../components/Panel/PanelCollectionObjects/PanelCollectionObjects.vue'
import PanelFieldOccurrences from '../components/Panel/PanelFieldOccurrences/PanelFieldOccurrences.vue'

export const PANEL_COMPONENTS = {
  NomenclatureHistory: {
    component: PanelTimeline,
    title: 'Timeline',
    status: 'stable'
  },

  PanelDescendants: {
    component: PanelDescendants,
    title: 'Descendants',
    status: 'prototype'
  },
  PanelDepictions: {
    component: PanelDepictions,
    title: 'Images',
    status: 'prototype'
  },
  PanelCommonNames: {
    component: PanelCommonNames,
    title: 'Common names',
    status: 'prototype'
  },
  PanelConveyance: {
    component: PanelConveyance,
    title: 'Sounds',
    status: 'prototype'
  },
  PanelDescription: {
    component: PanelDescription,
    title: 'Description',
    status: 'prototype'
  },
  PanelContent: {
    component: PanelContent,
    title: 'Content',
    status: 'prototype'
  },
  PanelBiologicalAssociations: {
    component: PanelBiologicalAssociations,
    title: 'Biological associations',
    status: 'prototype'
  },
  PanelAnnotations: {
    component: PanelAnnotations,
    title: 'Annotations',
    status: 'prototype'
  },
  PanelType: {
    component: PanelType,
    title: 'Type',
    status: 'prototype',
    rankGroup: ['FamilyGroup', 'GenusGroup']
  },
  PanelTypeSpecimens: {
    component: PanelTypeSpecimens,
    title: 'Type specimens',
    status: 'prototype',
    rankGroup: ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
  },
  PanelCollectionObjects: {
    component: PanelCollectionObjects,
    title: 'Specimen records',
    status: 'prototype',
    otu: true,
    rankGroup: ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
  },
  PanelFieldOccurrences: {
    component: PanelFieldOccurrences,
    title: 'Field occurrences',
    status: 'prototype',
    otu: true,
    rankGroup: ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
  },
  PanelAssertedDistribution: {
    component: PanelAssertedDistribution,
    title: 'Asserted distribution',
    status: 'prototype'
  },
  PanelDistribution: {
    component: PanelDistribution,
    title: 'Distribution',
    status: 'prototype'
  }
}
