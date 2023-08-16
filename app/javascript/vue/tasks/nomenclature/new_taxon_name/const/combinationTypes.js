import {
  TAXON_RELATIONSHIP_ORIGINAL_GENUS,
  TAXON_RELATIONSHIP_ORIGINAL_SUBGENUS,
  TAXON_RELATIONSHIP_ORIGINAL_SPECIES,
  TAXON_RELATIONSHIP_ORIGINAL_SUBSPECIES,
  TAXON_RELATIONSHIP_ORIGINAL_FORM,
  TAXON_RELATIONSHIP_ORIGINAL_SUBFORM,
  TAXON_RELATIONSHIP_ORIGINAL_VARIETY,
  TAXON_RELATIONSHIP_ORIGINAL_SUBVARIETY
} from '@/constants/index.js'

const genusGroup = {
  genus: TAXON_RELATIONSHIP_ORIGINAL_GENUS,
  subgenus: TAXON_RELATIONSHIP_ORIGINAL_SUBGENUS
}

const speciesGroup = {
  species: TAXON_RELATIONSHIP_ORIGINAL_SPECIES,
  subspecies: TAXON_RELATIONSHIP_ORIGINAL_SUBSPECIES
}

export const subsequentCombinationType = Object.freeze({
  genusGroup,
  speciesGroup
})

export const originalCombinationType = Object.freeze({
  genusGroup,
  speciesGroup: {
    ...speciesGroup,
    variety: TAXON_RELATIONSHIP_ORIGINAL_VARIETY,
    form: TAXON_RELATIONSHIP_ORIGINAL_FORM
  }
})

export const combinationIcnType = Object.freeze({
  genusGroup,
  speciesGroup: {
    ...speciesGroup,
    variety: TAXON_RELATIONSHIP_ORIGINAL_VARIETY,
    subvariety: TAXON_RELATIONSHIP_ORIGINAL_SUBVARIETY,
    form: TAXON_RELATIONSHIP_ORIGINAL_FORM,
    subform: TAXON_RELATIONSHIP_ORIGINAL_SUBFORM
  }
})
