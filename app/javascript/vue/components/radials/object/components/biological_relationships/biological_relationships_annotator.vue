<template>
  <div class="biological_relationships_annotator">
    <Teleport
      :to="`#${props.headerRightTargetId}`"
      :disabled="!props.headerRightTargetId"
    >
      <label class="support-ap-toggle">
        <input
          v-model="supportsAnatomicalPartCreation"
          type="checkbox"
        />
        Support anatomical parts creation
      </label>
    </Teleport>

    <template v-if="createdBiologicalAssociation">
      <div class="flex-separate">
        <h3>Edit mode</h3>
        <button
          type="button"
          class="button button-default"
          @click="reset"
        >
          Cancel
        </button>
      </div>
      <br />
    </template>

    <FormCitation
      v-model="citation"
      :klass="BIOLOGICAL_ASSOCIATION"
      lock-button
      use-session
      @lock="lock.source = $event"
    />

    <DisplayList
      v-if="createdBiologicalAssociation"
      edit
      class="margin-medium-top"
      label="citation_source_body"
      :list="createdBiologicalAssociation.citations"
      @edit="setCitation"
      @delete="removeCitation"
    />
    <div>
      <h3 v-html="metadata.object_tag" />

      <fieldset
        v-if="supportsAnatomicalPartCreation"
        class="ap-fieldset separate-bottom"
        :class="{ 'ap-fieldset--inactive': !enableSubjectAnatomicalPart }"
      >
        <legend>
          <label class="ap-fieldset-legend-toggle">
            <input
              v-model="enableSubjectAnatomicalPart"
              type="checkbox"
            />
            Subject anatomical part
          </label>
        </legend>

        <div
          v-if="!enableSubjectAnatomicalPart"
          class="ap-fieldset-hint"
        >
          Enable to create a subject anatomical part
        </div>

        <CreateAnatomicalPart
          v-else
          :key="`subject-${subjectPartKey}`"
          class="margin-small-top margin-small-bottom"
          :include-is-material="props.objectType === 'FieldOccurrence'"
          @change="setSubjectAnatomicalPart"
        />
      </fieldset>
      <h3
        v-if="biologicalRelationship"
        class="relationship-title middle"
      >
        <span
          v-html="
            flip
              ? biologicalRelationship.inverted_name
              : biologicalRelationLabel
          "
        />

        <VBtn
          v-if="biologicalRelationship.inverted_name"
          color="primary"
          @click="flip = !flip"
        >
          Flip
        </VBtn>

        <VBtn
          class="margin-small-left margin-small-right"
          color="primary"
          circle
          @click="unsetBiologicalRelationship"
        >
          <VIcon
            name="undo"
            small
          />
        </VBtn>
        <LockComponent v-model="lock.relationship" />
      </h3>
      <h3
        class="subtle relationship-title"
        v-else
      >
        Choose relationship
      </h3>

      <h3
        v-if="biologicalRelation"
        class="relation-title middle"
      >
        <span v-html="displayRelated" />
        <VBtn
          class="margin-small-left"
          color="primary"
          circle
          @click="biologicalRelation = undefined"
        >
          <VIcon
            name="undo"
            small
          />
        </VBtn>
      </h3>
      <h3
        v-else
        class="subtle relation-title"
      >
        Choose related OTU/collection object/field occurrence
      </h3>
    </div>
    <biological
      v-if="!biologicalRelationship"
      class="separate-bottom"
      @select="setBiologicalRelationship"
    />

    <related
      v-if="!biologicalRelation"
      ref="related"
      autofocus
      :target="BIOLOGICAL_ASSOCIATION"
      class="separate-bottom separate-top"
      @select="biologicalRelation = $event"
    />

    <fieldset
      v-if="supportsAnatomicalPartCreation"
      class="ap-fieldset separate-bottom"
      :class="{ 'ap-fieldset--inactive': !enableRelatedAnatomicalPart }"
    >
      <legend>
        <label class="ap-fieldset-legend-toggle">
          <input
            v-model="enableRelatedAnatomicalPart"
            type="checkbox"
          />
          Related anatomical part
        </label>
      </legend>

      <div
        v-if="!enableRelatedAnatomicalPart"
        class="ap-fieldset-hint"
      >
        Enable to create a related anatomical part
      </div>

      <template v-if="enableRelatedAnatomicalPart">
        <div
          v-if="biologicalRelation && relatedNeedsTaxonDetermination"
          class="margin-small-top"
        >
          The origin of an anatomical part requires a taxon determination on this {{ biologicalRelation.base_class }}.
        </div>

        <TaxonDeterminationOtu
          v-if="biologicalRelation && relatedNeedsTaxonDetermination"
          v-model="relatedTaxonDeterminationOtuId"
        />

        <CreateAnatomicalPart
          v-if="!relatedNeedsTaxonDetermination || relatedTaxonDeterminationOtuId || !biologicalRelation"
          :key="`related-${relatedPartKey}`"
          class="margin-small-top margin-small-bottom"
          :include-is-material="biologicalRelation?.base_class === 'FieldOccurrence'"
          :requires-is-material-before-template="biologicalRelation?.base_class === 'FieldOccurrence'"
          @change="setRelatedAnatomicalPart"
        />
      </template>
    </fieldset>

    <div class="separate-top">
      <button
        type="button"
        :disabled="!validateFields"
        @click="saveAssociation()"
        class="normal-input button button-submit"
      >
        {{ createdBiologicalAssociation ? 'Update' : 'Create' }}
      </button>
    </div>

    <TableList
      class="separate-top margin-large-bottom"
      :list="list"
      :metadata="metadata"
      @edit="editBiologicalRelationship"
      @delete="removeItem"
    />

    <template v-if="supportsAnatomicalPartCreation">
      <div class="anatomical-part-subject-table-block">
      <h3 class="anatomical-part-heading">
        <span>Anatomical parts of</span>
        <span
          class="anatomical-part-heading-object"
          v-html="anatomicalPartSubjectHeadingHtml"
        />
        <span>as subject:</span>
      </h3>
      <TableAnatomicalPartMode
        :list="anatomicalPartModeList"
        @edit="editBiologicalRelationship"
        @delete="removeItem"
      />
      </div>
    </template>
  </div>
</template>

<script setup>
import Biological from '@/components/Form/FormBiologicalAssociation/BiologicalAssociationRelationship.vue'
import Related from '@/components/Form/FormBiologicalAssociation/BiologicalAssociationRelated.vue'
import TaxonDeterminationOtu from '@/components/TaxonDetermination/TaxonDeterminationOtu.vue'
import TableList from './table.vue'
import TableAnatomicalPartMode from './table_anatomical_part_mode.vue'
import CreateAnatomicalPart from './components/CreateAnatomicalPart.vue'
import LockComponent from '@/components/ui/VLock/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import makeEmptyCitation from '../../helpers/makeEmptyCitation.js'
import DisplayList from '@/components/displayList.vue'
import { convertType } from '@/helpers/types'
import {
  BiologicalAssociation,
  BiologicalRelationship,
  TaxonDetermination
} from '@/routes/endpoints'
import { BIOLOGICAL_ASSOCIATION } from '@/constants/index.js'
import {
  ref,
  computed,
  watch,
  onBeforeMount,
  reactive,
  useTemplateRef,
  nextTick
} from 'vue'
import { useSlice } from '@/components/radials/composables'

const EXTEND_PARAMS = [
  'origin_citation',
  'object',
  'subject',
  'biological_relationship',
  'citations',
  'source'
]

const STORAGE_KEYS = {
  lockRelationship: 'radialObject::biologicalRelationship::lock',
  relationshipId: 'radialObject::biologicalRelationship::id',
  supportsAnatomicalPartCreation: 'radialObject::biologicalRelationship::supportsAnatomicalPartCreation',
  enableSubjectAnatomicalPart: 'radialObject::biologicalRelationship::enableSubjectAnatomicalPart',
  enableRelatedAnatomicalPart: 'radialObject::biologicalRelationship::enableRelatedAnatomicalPart'
}

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  metadata: {
    type: Object,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  },

  headerRightTargetId: {
    type: String,
    required: true
  }
})

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const relatedRef = useTemplateRef('related')

const biologicalRelation = ref()
const biologicalRelationship = ref()
const citation = ref(makeEmptyCitation())
const flip = ref(false)
const supportsAnatomicalPartCreation = ref(false)
const enableSubjectAnatomicalPart = ref(false)
const enableRelatedAnatomicalPart = ref(false)

const subjectAnatomicalPart = ref({ valid: false, payload: {} })
const relatedAnatomicalPart = ref({ valid: false, payload: {} })
const relatedTaxonDeterminationOtuId = ref(undefined)
const relatedNeedsTaxonDetermination = ref(false)
const subjectPartKey = ref(0)
const relatedPartKey = ref(0)
const anatomicalPartModeList = ref([])

const lock = reactive({
  source: false,
  relationship: false
})

const usesAnatomicalPartFlow = computed(
  () =>
    supportsAnatomicalPartCreation.value &&
    (enableSubjectAnatomicalPart.value || enableRelatedAnatomicalPart.value)
)

const canAutoSaveOnRelatedSelection = computed(() => {
  if (!biologicalRelation.value?.id) {
    return false
  }

  if (!citation.value.source_id || !biologicalRelationship.value?.id) {
    return false
  }

  // AP support mode is explicit-create only.
  if (supportsAnatomicalPartCreation.value) {
    return false
  }

  return true
})

const validateFields = computed(() => {
  const hasBaseFields = biologicalRelationship.value && biologicalRelation.value

  if (!hasBaseFields) {
    return false
  }

  if (!usesAnatomicalPartFlow.value) {
    return true
  }

  if (enableSubjectAnatomicalPart.value && !subjectAnatomicalPart.value.valid) {
    return false
  }

  if (!enableRelatedAnatomicalPart.value) {
    return true
  }

  if (relatedNeedsTaxonDetermination.value && !relatedTaxonDeterminationOtuId.value) {
    return false
  }

  return relatedAnatomicalPart.value.valid
})

const displayRelated = computed(() => {
  return (
    biologicalRelation.value?.object_tag || biologicalRelation.value?.label_html
  )
})

const createdBiologicalAssociation = computed(() =>
  supportsAnatomicalPartCreation.value
    ? undefined
    : list.value.find(
        (item) =>
          item.biological_relationship_id === biologicalRelationship.value?.id &&
          item.biological_association_object_id === biologicalRelation.value?.id
      )
)

const biologicalRelationLabel = computed(
  () =>
    biologicalRelationship.value?.name ||
    biologicalRelationship.value?.object_label
)

const anatomicalPartSubjectHeadingHtml = computed(() => {
  if (props.metadata.object_tag) {
    return props.metadata.object_tag
  }

  return props.metadata.object_label || 'selected object'
})

watch(
  () => lock.relationship,
  (newVal) => {
    sessionStorage.setItem(STORAGE_KEYS.lockRelationship, newVal)
  }
)

watch(
  supportsAnatomicalPartCreation,
  (newVal) => {
    sessionStorage.setItem(STORAGE_KEYS.supportsAnatomicalPartCreation, newVal)

    if (newVal) {
      loadAnatomicalPartModeList()
    }
  }
)

watch(
  enableSubjectAnatomicalPart,
  (newVal) => {
    sessionStorage.setItem(STORAGE_KEYS.enableSubjectAnatomicalPart, newVal)

    if (!newVal) {
      subjectAnatomicalPart.value = { valid: false, payload: {} }
      subjectPartKey.value += 1
    }
  }
)

watch(
  enableRelatedAnatomicalPart,
  (newVal) => {
    sessionStorage.setItem(STORAGE_KEYS.enableRelatedAnatomicalPart, newVal)

    relatedTaxonDeterminationOtuId.value = undefined
    relatedNeedsTaxonDetermination.value = false
    relatedAnatomicalPart.value = { valid: false, payload: {} }
    relatedPartKey.value += 1

    if (newVal && biologicalRelation.value?.id) {
      updateRelatedTaxonDeterminationState()
    }
  }
)

watch(biologicalRelation, () => {
  relatedTaxonDeterminationOtuId.value = undefined
  relatedNeedsTaxonDetermination.value = false
  relatedAnatomicalPart.value = { valid: false, payload: {} }
  relatedPartKey.value += 1

  if (enableRelatedAnatomicalPart.value && biologicalRelation.value?.id) {
    updateRelatedTaxonDeterminationState()
  }

  if (canAutoSaveOnRelatedSelection.value) {
    saveAssociation()
  }
})

onBeforeMount(() => {
  const relationshipLock = convertType(
    sessionStorage.getItem(STORAGE_KEYS.lockRelationship)
  )

  if (relationshipLock !== null) {
    lock.relationship = relationshipLock === true
  }

  supportsAnatomicalPartCreation.value =
    convertType(sessionStorage.getItem(STORAGE_KEYS.supportsAnatomicalPartCreation)) === true
  enableSubjectAnatomicalPart.value =
    convertType(sessionStorage.getItem(STORAGE_KEYS.enableSubjectAnatomicalPart)) === true
  enableRelatedAnatomicalPart.value =
    convertType(sessionStorage.getItem(STORAGE_KEYS.enableRelatedAnatomicalPart)) === true

  if (lock.relationship) {
    const relationshipId = convertType(
      sessionStorage.getItem(STORAGE_KEYS.relationshipId)
    )

    if (relationshipId) {
      BiologicalRelationship.find(relationshipId).then(({ body }) => {
        biologicalRelationship.value = body
      })
    }
  }

  BiologicalAssociation.where({
    biological_association_subject_id: props.objectId,
    biological_association_subject_type: props.objectType,
    extend: EXTEND_PARAMS,
    recent: true
  }).then(({ body }) => {
    list.value = body
  })

  if (supportsAnatomicalPartCreation.value) {
    loadAnatomicalPartModeList()
  }
})


function reset() {
  if (!lock.relationship) {
    biologicalRelationship.value = undefined
  }
  biologicalRelation.value = undefined
  flip.value = false

  subjectAnatomicalPart.value = { valid: false, payload: {} }
  relatedAnatomicalPart.value = { valid: false, payload: {} }
  relatedTaxonDeterminationOtuId.value = undefined
  relatedNeedsTaxonDetermination.value = false
  subjectPartKey.value += 1
  relatedPartKey.value += 1

  if (lock.source) {
    citation.value.id = undefined
  } else {
    citation.value = makeEmptyCitation()
  }
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
  if (!biologicalRelation.value?.id || !relatedIsCollectionObjectOrFieldOccurrence()) {
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
    !supportsAnatomicalPartCreation.value ||
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
      mapped.object_anatomical_part_attributes = subjectAnatomicalPart.value.payload
    } else {
      mapped.subject_anatomical_part_attributes = subjectAnatomicalPart.value.payload
    }
  }

  if (enableRelatedAnatomicalPart.value) {
    if (flip.value) {
      mapped.subject_anatomical_part_attributes = relatedAnatomicalPart.value.payload
    } else {
      mapped.object_anatomical_part_attributes = relatedAnatomicalPart.value.payload
    }

    if (relatedNeedsTaxonDetermination.value && relatedTaxonDeterminationOtuId.value) {
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

async function saveAssociation() {
  if (!(await ensureRelatedTaxonDeterminationRequirements())) {
    return
  }

  const payload = {
    biological_association: {
      ...(flip.value
        ? {
            biological_association_object_id: props.objectId,
            biological_association_object_type: props.objectType,
            biological_association_subject_id: biologicalRelation.value.id,
            biological_association_subject_type:
              biologicalRelation.value.base_class
          }
        : {
            biological_association_object_id: biologicalRelation.value.id,
            biological_association_object_type:
              biologicalRelation.value.base_class,
            biological_association_subject_id: props.objectId,
            biological_association_subject_type: props.objectType
          }),
      biological_relationship_id: biologicalRelationship.value.id,
      citations_attributes: citation.value ? [citation.value] : undefined,
      ...mapAnatomicalPartAttributesToAssociationSides()
    },
    extend: EXTEND_PARAMS
  }

  const saveRequest = createdBiologicalAssociation.value
    ? BiologicalAssociation.update(
        createdBiologicalAssociation.value.id,
        payload
      )
    : BiologicalAssociation.create(payload)

  saveRequest
    .then(({ body }) => {
      addToList(body)
      if (supportsAnatomicalPartCreation.value) {
        loadAnatomicalPartModeList()
      }
      reset()
      TW.workbench.alert.create(
        'Biological association was successfully saved.',
        'notice'
      )

      nextTick(() => {
        relatedRef.value.setFocus()
      })
    })
    .catch(() => {})
}

function removeItem(item) {
  BiologicalAssociation.destroy(item.id).then(() => {
    removeFromList(item)
    if (supportsAnatomicalPartCreation.value) {
      loadAnatomicalPartModeList()
    }
  })
}

function loadAnatomicalPartModeList() {
  BiologicalAssociation.originSubjectIndex({
    origin_object_id: props.objectId,
    origin_object_type: props.objectType,
    extend: EXTEND_PARAMS
  }).then(({ body }) => {
    anatomicalPartModeList.value = body
  })
}

function setCitation(existingCitation) {
  citation.value = {
    id: existingCitation.id,
    pages: existingCitation.pages,
    source_id: existingCitation.source_id,
    is_original: existingCitation.is_original
  }
}

function removeCitation(item) {
  const payload = {
    biological_association: {
      citations_attributes: [
        {
          id: item.id,
          _destroy: true
        }
      ]
    },
    extend: EXTEND_PARAMS
  }

  BiologicalAssociation.update(
    createdBiologicalAssociation.value.id,
    payload
  ).then(({ body }) => {
    removeFromList(body)
  })
}

function editBiologicalRelationship(bioRelation) {
  biologicalRelationship.value = {
    id: bioRelation.biological_relationship_id,
    ...bioRelation.biological_relationship
  }

  biologicalRelation.value = {
    id: bioRelation.biological_association_object_id,
    ...bioRelation.object
  }
  flip.value = bioRelation.object.id === props.objectId
}

function setBiologicalRelationship(item) {
  biologicalRelationship.value = item
  sessionStorage.setItem(STORAGE_KEYS.relationshipId, item.id)
}

function unsetBiologicalRelationship() {
  biologicalRelationship.value = undefined
  flip.value = false
}
</script>
<style lang="scss">
.radial-annotator {
  .biological_relationships_annotator {
    .support-ap-toggle {
      display: inline-flex;
      align-items: center;
      gap: 0.25rem;
    }

    .flip-button {
      min-width: 30px;
    }

    .relationship-title {
      margin-left: 1em;
    }

    .relation-title {
      margin-left: 2em;
    }

    .background-info {
      padding: 3px;
      padding-left: 6px;
      padding-right: 6px;
      border-radius: 3px;
      background-color: #ded2f9;
    }

    .anatomical-part-subject-table-block {
      margin-top: 1rem;
      padding-top: 0.75rem;
      border-top: 1px solid #d9d9d9;
    }

    .ap-fieldset {
      border: 1px solid var(--border-color);
      padding: 0.5rem 0.75rem;
      border-radius: var(--border-radius-small);
    }

    .ap-fieldset--inactive {
      opacity: 0.88;
    }

    .ap-fieldset-legend-toggle {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      font-weight: 600;
      cursor: pointer;
    }

    .ap-fieldset-hint {
      color: var(--text-muted-color);
      font-size: 0.9rem;
      line-height: 1.3;
    }

    .anatomical-part-heading {
      display: inline-flex;
      align-items: center;
      flex-wrap: wrap;
      gap: 0.35rem;
      margin: 0;
    }

    .anatomical-part-heading-object {
      display: inline-flex;
      align-items: center;
      line-height: 1;
    }
  }
}
</style>
