import { computed, ref, watch } from 'vue'
import { TaxonDetermination } from '@/routes/endpoints'

const STORAGE_KEYS = {
  withAnatomicalPartCreation:
    'radialObject::biologicalRelationship::withAnatomicalPartCreation',
  enableSubjectAnatomicalPart:
    'radialObject::biologicalRelationship::enableSubjectAnatomicalPart',
  enableRelatedAnatomicalPart:
    'radialObject::biologicalRelationship::enableRelatedAnatomicalPart'
}

export default function useBiologicalAssociationAnatomicalParts({
  convertType,
  biologicalRelation,
  flip,
  createdBiologicalAssociation,
  loadAnatomicalPartModeList
}) {
  const withAnatomicalPartCreation = ref(false)
  const enableSubjectAnatomicalPart = ref(false)
  const enableRelatedAnatomicalPart = ref(false)

  const subjectAnatomicalPart = ref({ valid: false, payload: {} })
  const relatedAnatomicalPart = ref({ valid: false, payload: {} })
  const relatedTaxonDeterminationOtuId = ref(undefined)
  const relatedNeedsTaxonDetermination = ref(false)
  const subjectPartKey = ref(0)
  const relatedPartKey = ref(0)
  const anatomicalPartModeList = ref([])

  const usesAnatomicalPartFlow = computed(
    () =>
      withAnatomicalPartCreation.value &&
      (enableSubjectAnatomicalPart.value || enableRelatedAnatomicalPart.value)
  )

  function validateAnatomicalPartFields() {
    if (!usesAnatomicalPartFlow.value) {
      return true
    }

    if (
      enableSubjectAnatomicalPart.value &&
      !subjectAnatomicalPart.value.valid
    ) {
      return false
    }

    if (!enableRelatedAnatomicalPart.value) {
      return true
    }

    if (
      relatedNeedsTaxonDetermination.value &&
      !relatedTaxonDeterminationOtuId.value
    ) {
      return false
    }

    return relatedAnatomicalPart.value.valid
  }

  function resetAnatomicalPartState() {
    subjectAnatomicalPart.value = { valid: false, payload: {} }
    relatedAnatomicalPart.value = { valid: false, payload: {} }
    relatedTaxonDeterminationOtuId.value = undefined
    relatedNeedsTaxonDetermination.value = false
    subjectPartKey.value += 1
    relatedPartKey.value += 1
  }

  function setSubjectAnatomicalPart(data) {
    subjectAnatomicalPart.value = data
  }

  function setRelatedAnatomicalPart(data) {
    relatedAnatomicalPart.value = data
  }

  function relatedIsCollectionObjectOrFieldOccurrence() {
    const type = biologicalRelation.value?.base_class
    return ['CollectionObject', 'FieldOccurrence'].includes(type)
  }

  function fetchRelatedNeedsTaxonDetermination() {
    if (
      !biologicalRelation.value?.id ||
      !relatedIsCollectionObjectOrFieldOccurrence()
    ) {
      return Promise.resolve(false)
    }

    return TaxonDetermination.where({
      taxon_determination_object_id: [biologicalRelation.value.id],
      taxon_determination_object_type: biologicalRelation.value.base_class,
      per: 1
    }).then(({ body }) => body.length === 0)
  }

  function updateRelatedTaxonDeterminationState() {
    fetchRelatedNeedsTaxonDetermination().then((needsTaxonDetermination) => {
      relatedNeedsTaxonDetermination.value = needsTaxonDetermination
    })
  }

  async function ensureRelatedTaxonDeterminationRequirements() {
    if (
      !withAnatomicalPartCreation.value ||
      !enableRelatedAnatomicalPart.value ||
      !biologicalRelation.value?.id
    ) {
      return true
    }

    const needsTaxonDetermination = await fetchRelatedNeedsTaxonDetermination()
    relatedNeedsTaxonDetermination.value = needsTaxonDetermination

    if (needsTaxonDetermination && !relatedTaxonDeterminationOtuId.value) {
      TW.workbench.alert.create(
        'A taxon determination OTU is required for the related anatomical part.',
        'warning'
      )
      return false
    }

    return true
  }

  function mapAnatomicalPartAttributesToAssociationSides() {
    const mapped = {}

    if (!usesAnatomicalPartFlow.value || createdBiologicalAssociation.value) {
      return mapped
    }

    if (enableSubjectAnatomicalPart.value) {
      if (flip.value) {
        mapped.object_anatomical_part_attributes =
          subjectAnatomicalPart.value.payload
      } else {
        mapped.subject_anatomical_part_attributes =
          subjectAnatomicalPart.value.payload
      }
    }

    if (enableRelatedAnatomicalPart.value) {
      if (flip.value) {
        mapped.subject_anatomical_part_attributes =
          relatedAnatomicalPart.value.payload
      } else {
        mapped.object_anatomical_part_attributes =
          relatedAnatomicalPart.value.payload
      }

      if (
        relatedNeedsTaxonDetermination.value &&
        relatedTaxonDeterminationOtuId.value
      ) {
        if (flip.value) {
          mapped.subject_taxon_determination_attributes = {
            otu_id: relatedTaxonDeterminationOtuId.value
          }
        } else {
          mapped.object_taxon_determination_attributes = {
            otu_id: relatedTaxonDeterminationOtuId.value
          }
        }
      }
    }

    return mapped
  }

  watch(withAnatomicalPartCreation, (newVal) => {
    sessionStorage.setItem(STORAGE_KEYS.withAnatomicalPartCreation, newVal)

    if (newVal) {
      loadAnatomicalPartModeList()
    }
  })

  watch(enableSubjectAnatomicalPart, (newVal) => {
    sessionStorage.setItem(STORAGE_KEYS.enableSubjectAnatomicalPart, newVal)

    if (!newVal) {
      subjectAnatomicalPart.value = { valid: false, payload: {} }
      subjectPartKey.value += 1
    }
  })

  watch(enableRelatedAnatomicalPart, (newVal) => {
    sessionStorage.setItem(STORAGE_KEYS.enableRelatedAnatomicalPart, newVal)

    relatedTaxonDeterminationOtuId.value = undefined
    relatedNeedsTaxonDetermination.value = false
    relatedAnatomicalPart.value = { valid: false, payload: {} }
    relatedPartKey.value += 1

    if (newVal && biologicalRelation.value?.id) {
      updateRelatedTaxonDeterminationState()
    }
  })

  watch(biologicalRelation, () => {
    relatedTaxonDeterminationOtuId.value = undefined
    relatedNeedsTaxonDetermination.value = false
    relatedAnatomicalPart.value = { valid: false, payload: {} }
    relatedPartKey.value += 1

    if (enableRelatedAnatomicalPart.value && biologicalRelation.value?.id) {
      updateRelatedTaxonDeterminationState()
    }
  })

  function loadAnatomicalPartSessionState() {
    withAnatomicalPartCreation.value =
      convertType(
        sessionStorage.getItem(STORAGE_KEYS.withAnatomicalPartCreation)
      ) === true

    enableSubjectAnatomicalPart.value =
      convertType(sessionStorage.getItem(STORAGE_KEYS.enableSubjectAnatomicalPart)) ===
      true

    enableRelatedAnatomicalPart.value =
      convertType(sessionStorage.getItem(STORAGE_KEYS.enableRelatedAnatomicalPart)) ===
      true
  }

  return {
    withAnatomicalPartCreation,
    enableSubjectAnatomicalPart,
    enableRelatedAnatomicalPart,
    subjectAnatomicalPart,
    relatedAnatomicalPart,
    relatedTaxonDeterminationOtuId,
    relatedNeedsTaxonDetermination,
    subjectPartKey,
    relatedPartKey,
    anatomicalPartModeList,
    usesAnatomicalPartFlow,
    validateAnatomicalPartFields,
    resetAnatomicalPartState,
    setSubjectAnatomicalPart,
    setRelatedAnatomicalPart,
    updateRelatedTaxonDeterminationState,
    ensureRelatedTaxonDeterminationRequirements,
    mapAnatomicalPartAttributesToAssociationSides,
    loadAnatomicalPartSessionState
  }
}
