<template>
  <div class="biological_relationships_annotator">
    <Teleport
      :to="`#${props.headerRightTargetId}`"
      :disabled="!props.headerRightTargetId"
    >
      <label class="support-ap-toggle">
        <input
          v-model="withAnatomicalPartCreation"
          type="checkbox"
        />
        With anatomical parts
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

      <AnatomicalPartToggleFieldset
        v-if="withAnatomicalPartCreation"
        v-model="enableSubjectAnatomicalPart"
        label="Subject anatomical part"
        hint="Enable to create a subject anatomical part"
      >
        <div
          v-if="subjectNeedsTaxonDetermination"
          class="margin-small-top"
        >
          The origin of an anatomical part requires a taxon determination on this {{ props.objectType }}.
        </div>

        <TaxonDeterminationOtu
          v-if="subjectNeedsTaxonDetermination"
          v-model="subjectTaxonDeterminationOtuId"
        />

        <CreateAnatomicalPart
          v-if="!subjectNeedsTaxonDetermination || subjectTaxonDeterminationOtuId"
          :key="`subject-${subjectPartKey}`"
          class="margin-small-top margin-small-bottom"
          :include-is-material="props.objectType === 'FieldOccurrence'"
          @change="setSubjectAnatomicalPart"
        />
      </AnatomicalPartToggleFieldset>

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

    <AnatomicalPartToggleFieldset
      v-if="withAnatomicalPartCreation"
      v-model="enableRelatedAnatomicalPart"
      label="Related anatomical part"
      hint="Enable to create a related anatomical part"
    >
      <RelatedAnatomicalPartPanel
        :enabled="enableRelatedAnatomicalPart"
        :biological-relation="biologicalRelation"
        :related-needs-taxon-determination="relatedNeedsTaxonDetermination"
        v-model:related-taxon-determination-otu-id="relatedTaxonDeterminationOtuId"
        :related-part-key="relatedPartKey"
        @change="setRelatedAnatomicalPart"
      />
    </AnatomicalPartToggleFieldset>

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

    <AnatomicalPartSubjectSummary
      v-if="withAnatomicalPartCreation"
      :list="anatomicalPartModeList"
      :metadata="metadata"
      :subject-heading-html="anatomicalPartSubjectHeadingHtml"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import Biological from '@/components/Form/FormBiologicalAssociation/BiologicalAssociationRelationship.vue'
import Related from '@/components/Form/FormBiologicalAssociation/BiologicalAssociationRelated.vue'
import TableList from './table.vue'
import CreateAnatomicalPart from './components/CreateAnatomicalPart.vue'
import AnatomicalPartToggleFieldset from './components/AnatomicalPartToggleFieldset.vue'
import RelatedAnatomicalPartPanel from './components/RelatedAnatomicalPartPanel.vue'
import AnatomicalPartSubjectSummary from './components/AnatomicalPartSubjectSummary.vue'
import TaxonDeterminationOtu from '@/components/TaxonDetermination/TaxonDeterminationOtu.vue'
import useBiologicalAssociationAnatomicalParts from './composables/useBiologicalAssociationAnatomicalParts.js'
import LockComponent from '@/components/ui/VLock/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import makeEmptyCitation from '../../helpers/makeEmptyCitation.js'
import DisplayList from '@/components/displayList.vue'
import { convertType } from '@/helpers/types'
import {
  BiologicalAssociation,
  BiologicalRelationship
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
  relationshipId: 'radialObject::biologicalRelationship::id'
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

const lock = reactive({
  source: false,
  relationship: false
})

const canAutoSaveOnRelatedSelection = computed(() => {
  if (!biologicalRelation.value?.id) {
    return false
  }

  if (!citation.value.source_id || !biologicalRelationship.value?.id) {
    return false
  }

  // AnatomicalPart support mode is explicit-create only.
  if (withAnatomicalPartCreation.value) {
    return false
  }

  return true
})

const validateFields = computed(() => {
  const hasBaseFields = biologicalRelationship.value && biologicalRelation.value

  if (!hasBaseFields) {
    return false
  }

  return validateAnatomicalPartFields()
})

const displayRelated = computed(() => {
  return (
    biologicalRelation.value?.object_tag || biologicalRelation.value?.label_html
  )
})

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

const {
  withAnatomicalPartCreation,
  enableSubjectAnatomicalPart,
  enableRelatedAnatomicalPart,
  subjectTaxonDeterminationOtuId,
  subjectNeedsTaxonDetermination,
  relatedTaxonDeterminationOtuId,
  relatedNeedsTaxonDetermination,
  subjectPartKey,
  relatedPartKey,
  anatomicalPartModeList,
  createdBiologicalAssociation,
  validateAnatomicalPartFields,
  resetAnatomicalPartState,
  setSubjectAnatomicalPart,
  setRelatedAnatomicalPart,
  ensureTaxonDeterminationRequirements,
  mapAnatomicalPartAttributesToAssociationSides,
  loadAnatomicalPartSessionState
} = useBiologicalAssociationAnatomicalParts({
  convertType,
  list,
  biologicalRelationship,
  biologicalRelation,
  flip,
  loadAnatomicalPartModeList,
  objectId: props.objectId,
  objectType: props.objectType
})

watch(
  () => lock.relationship,
  (newVal) => {
    sessionStorage.setItem(STORAGE_KEYS.lockRelationship, newVal)
  }
)

watch(biologicalRelation, () => {
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

  loadAnatomicalPartSessionState()
  // The withAnatomicalPartCreation watcher fires after session state is set, loading the AP mode list if needed.

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

})


function reset() {
  if (!lock.relationship) {
    biologicalRelationship.value = undefined
  }
  biologicalRelation.value = undefined
  flip.value = false

  resetAnatomicalPartState()

  if (lock.source) {
    citation.value.id = undefined
  } else {
    citation.value = makeEmptyCitation()
  }
}

async function saveAssociation() {
  if (!(await ensureTaxonDeterminationRequirements())) {
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
      if (withAnatomicalPartCreation.value) {
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
    if (withAnatomicalPartCreation.value) {
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

    .anatomical-part-summary-heading {
      font-size: 1rem;
      font-weight: 500;
      color: var(--text-muted-color);
      min-width: 0;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
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

    .ap-table-modal-body {
      max-height: 70vh;
      overflow: auto;
    }
  }
}
</style>
