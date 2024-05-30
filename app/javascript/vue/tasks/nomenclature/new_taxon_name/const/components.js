import AuthorSection from '../components/Author/Author.vue'
import ClassificationSection from '../components/classification.vue'
import EtymologySection from '../components/etymology.vue'
import GenderSection from '../components/gender.vue'
import ManagesynonymySection from '../components/manageSynonym'
import OriginalFormSection from '../components/OriginalForm.vue'
import OriginalcombinationSection from '../components/pickOriginalCombination.vue'
import RelationshipSection from '../components/relationshipPicker.vue'
import StatusSection from '../components/statusPicker.vue'
import SubsequentCombinationSection from '../components/Combination/CombinationMain.vue'
import SubsequentNameFormSection from '../components/SubsequentNameForm/SubsequentNameForm.vue'
import TaxonSection from '../components/basicInformation.vue'
import TypeSection from '../components/type.vue'
import showForThisGroup from '../helpers/showForThisGroup'

export const SectionComponents = [
  {
    title: 'Taxon',
    component: TaxonSection,
    isAvailableFor: () => true
  },

  {
    title: 'Author',
    component: AuthorSection,
    isAvailableFor: () => true
  },

  {
    title: 'Status',
    component: StatusSection,
    isAvailableFor: () => true
  },

  {
    title: 'Relationship',
    component: RelationshipSection,
    isAvailableFor: () => true
  },

  {
    title: 'Manage synonymy',
    component: ManagesynonymySection,
    isAvailableFor: (taxon) =>
      showForThisGroup(['GenusGroup', 'FamilyGroup'], taxon) &&
      !taxon.cached_is_valid
  },

  {
    title: 'Type',
    component: TypeSection,
    isAvailableFor: (taxon) =>
      showForThisGroup(
        [
          'SpeciesGroup',
          'GenusGroup',
          'FamilyGroup',
          'SpeciesAndInfraspeciesGroup'
        ],
        taxon
      )
  },

  {
    title: 'Original combination',
    component: OriginalcombinationSection,
    isAvailableFor: (taxon) =>
      showForThisGroup(
        ['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'],
        taxon
      )
  },

  {
    title: 'Subsequent Combination',
    component: SubsequentCombinationSection,
    isAvailableFor: (taxon) =>
      showForThisGroup(
        ['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'],
        taxon
      )
  },

  {
    title: 'Original Form',
    component: OriginalFormSection,
    isAvailableFor: (taxon) => showForThisGroup(['FamilyGroup'], taxon)
  },

  {
    title: 'Subsequent Name Form',
    component: SubsequentNameFormSection,
    isAvailableFor: (taxon) => showForThisGroup(['FamilyGroup'], taxon)
  },

  {
    title: 'Classification',
    component: ClassificationSection,
    isAvailableFor: () => true
  },

  {
    title: 'Gender',
    component: GenderSection,
    isAvailableFor: (taxon) =>
      showForThisGroup(
        ['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'],
        taxon
      )
  },

  {
    title: 'Etymology',
    component: EtymologySection,
    isAvailableFor: (taxon) =>
      showForThisGroup(
        ['SpeciesGroup', 'GenusGroup', 'SpeciesAndInfraspeciesGroup'],
        taxon
      )
  }
]
