/* 
import ContentComponent from './components/Content'
import ConveyanceComponent from './components/Conveyance/PanelConveyance.vue'
import AssertedDistribution from './components/AssertedDistribution'
import BiologicalAssociations from './components/BiologicalAssociations'
import AnnotationsComponent from './components/Annotations'
import NomenclatureHistory from './components/timeline/Timeline.vue' */
import PanelDistribution from '../components/Panel/PanelDistribution/PanelDistribution.vue'
import PanelCoordinate from '../components/Panel/PanelCoordinates/PanelCoordinates.vue'
import PanelDepictions from '../components/Panel/PanelDepictions/PanelDepictions.vue'
/* import Descendants from './components/Descendants/Descendants.vue'
import CollectionObjects from './components/CollectionObjects'
import TypeSpecimens from './components/specimens/Type'
import TypeSection from './components/TypeSection.vue'
import CommonNames from './components/CommonNames'
import DescriptionComponent from './components/Description.vue'

import FieldOccurrences from './components/FieldOccurrence/FieldOccurrence.vue' */

export const PANEL_COMPONENTS = {
  PanelCoordinate: {
    component: PanelCoordinate,
    title: 'Coordinate OTUs',
    status: 'stable'
  },
  /*
  NomenclatureHistory: {
    component: NomenclatureHistory,
    title: 'Timeline',
    status: 'stable'
  },
  Descendants: {
    component: Descendants,
    title: 'Descendants',
    status: 'prototype'
  },*/
  PanelDepictions: {
    component: PanelDepictions,
    title: 'Images',
    status: 'prototype'
  } /*
  ConveyanceComponent: {
    component: ConveyanceComponent,
    title: 'Sounds',
    status: 'prototype'
  },
  CommonNames: {
    component: CommonNames,
    title: 'Common names',
    status: 'prototype'
  },
  TypeSection: {
    component: TypeSection,
    title: 'Type',
    status: 'prototype',
    rankGroup: ['FamilyGroup', 'GenusGroup']
  },
  TypeSpecimens: {
    component: TypeSpecimens,
    title: 'Type specimens',
    status: 'prototype',
    rankGroup: ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
  },
  CollectionObjects: {
    component: CollectionObjects,
    title: 'Specimen records',
    status: 'prototype',
    otu: true,
    rankGroup: ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
  },
  FieldOccurrences: {
    component: FieldOccurrences,
    title: 'Field occurrences',
    status: 'prototype',
    otu: true,
    rankGroup: ['SpeciesGroup', 'SpeciesAndInfraspeciesGroup']
  },
  DescriptionComponent: {
    component: DescriptionComponent,
    title: 'Description',
    status: 'prototype'
  },
  ContentComponent: {
    component: ContentComponent,
    title: 'Content',
    status: 'prototype'
  },
  AssertedDistribution: {
    component: AssertedDistribution,
    title: 'Asserted distribution',
    status: 'prototype'
  },
  BiologicalAssociations: {
    component: BiologicalAssociations,
    title: 'Biological associations',
    status: 'prototype'
  },
  AnnotationsComponent: {
    component: AnnotationsComponent,
    title: 'Annotations',
    status: 'prototype'
  }, */,
  PanelDistribution: {
    component: PanelDistribution,
    title: 'Distribution',
    status: 'prototype'
  }
}
