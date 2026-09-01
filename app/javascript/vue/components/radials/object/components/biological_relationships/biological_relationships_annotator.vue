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

    <EditingBanner
      v-if="createdBiologicalAssociation"
      :label="createdBiologicalAssociation.object_tag"
      @close="reset"
    />

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
        v-if="
          withAnatomicalPartCreation && props.objectType !== 'AnatomicalPart'
        "
        v-model="enableSubjectAnatomicalPart"
        label="Subject anatomical part"
        hint="Enable to create a subject anatomical part"
      >
        <div
          v-if="subjectNeedsTaxonDetermination"
          class="margin-small-top"
        >
          The origin of an anatomical part requires a taxon determination on
          this {{ props.objectType }}.
        </div>

        <TaxonDeterminationOtu
          v-if="subjectNeedsTaxonDetermination"
          v-model="subjectTaxonDeterminationOtuId"
        />

        <CreateAnatomicalPart
          v-if="
            !subjectNeedsTaxonDetermination || subjectTaxonDeterminationOtuId
          "
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
            flip ? biologicalRelationship.inverted_name : relatedObjectLabel
          "
        />

        <VBtn
          v-if="biologicalRelationship.inverted_name"
          color="primary"
          @click="flip = !flip"
          class="margin-small-left"
        >
          Flip
        </VBtn>

        <VBtn
          class="margin-small-left margin-small-right"
          color="primary"
          icon
          variant="tonal"
          @click="unsetBiologicalRelationship"
        >
          <IconReset class="w-4 h-4" />
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
        v-if="relatedObject"
        class="relation-title middle"
      >
        <span v-html="displayRelated" />
        <VBtn
          class="margin-small-left"
          color="primary"
          icon
          variant="tonal"
          @click="relatedObject = undefined"
        >
          <IconReset class="w-4 h-4" />
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
      v-if="!relatedObject"
      ref="related"
      autofocus
      :target="BIOLOGICAL_ASSOCIATION"
      class="separate-bottom separate-top"
      @select="relatedObject = $event"
    />

    <AnatomicalPartToggleFieldset
      v-if="withAnatomicalPartCreation"
      v-model="enableRelatedAnatomicalPart"
      label="Related anatomical part"
      hint="Enable to create a related anatomical part"
    >
      <RelatedAnatomicalPartPanel
        :enabled="enableRelatedAnatomicalPart"
        :related-object="relatedObject"
        :related-needs-taxon-determination="relatedNeedsTaxonDetermination"
        v-model:related-taxon-determination-otu-id="
          relatedTaxonDeterminationOtuId
        "
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

    <VSwitch
      class="separate-top list-mode-switch"
      v-model="listMode"
      name="ba-list-mode"
      :options="LIST_MODES"
    />

    <VPagination
      v-if="pagination.totalPages > 1"
      class="separate-top"
      :pagination="pagination"
      @next-page="({ page }) => loadList(page)"
    />

    <TableList
      class="separate-top margin-large-bottom"
      :list="list"
      :metadata="metadata"
      @edit="editBiologicalRelationship"
      @delete="removeItem"
    />

    <VPagination
      v-if="pagination.totalPages > 1"
      :pagination="pagination"
      @next-page="({ page }) => loadList(page)"
    />

    <AnatomicalPartSubjectSummary
      v-if="withAnatomicalPartCreation && props.objectType !== 'AnatomicalPart'"
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
import EditingBanner from '@/components/ui/EditingBanner/EditingBanner.vue'
import IconReset from '@/components/Icon/IconReset.vue'
import FormCitation from '@/components/Form/FormCitation.vue'
import VPagination from '@/components/pagination.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import makeEmptyCitation from '../../helpers/makeEmptyCitation.js'
import DisplayList from '@/components/displayList.vue'
import { convertType } from '@/helpers/types'
import { getPagination } from '@/helpers'
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
  relationshipId: 'radialObject::biologicalRelationship::id',
  listMode: 'radialObject::biologicalRelationship::listMode'
}

const LIST_MODES = ['Subject', 'Object', 'Both']

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

const relatedObject = ref()
const biologicalRelationship = ref()
const citation = ref(makeEmptyCitation())
const flip = ref(false)
const pagination = ref({})
const listMode = ref(storedListMode())

const PER_PAGE = 50

const lock = reactive({
  source: false,
  relationship: false
})

const canAutoSaveOnRelatedSelection = computed(() => {
  if (!relatedObject.value?.id) {
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
  const hasBaseFields = biologicalRelationship.value && relatedObject.value

  if (!hasBaseFields) {
    return false
  }

  return validateAnatomicalPartFields()
})

const displayRelated = computed(() => {
  return relatedObject.value?.object_tag || relatedObject.value?.label_html
})

const relatedObjectLabel = computed(
  () =>
    biologicalRelationship.value?.name ||
    biologicalRelationship.value?.object_label
)

const {
  anatomicalPartModeList,
  anatomicalPartSubjectHeadingHtml,
  createdBiologicalAssociation,
  enableRelatedAnatomicalPart,
  enableSubjectAnatomicalPart,
  ensureTaxonDeterminationRequirements,
  loadAnatomicalPartModeList,
  loadAnatomicalPartSessionState,
  mapAnatomicalPartAttributesToAssociationSides,
  relatedNeedsTaxonDetermination,
  relatedPartKey,
  relatedTaxonDeterminationOtuId,
  validateAnatomicalPartFields,
  resetAnatomicalPartState,
  setRelatedAnatomicalPart,
  setSubjectAnatomicalPart,
  subjectNeedsTaxonDetermination,
  subjectPartKey,
  subjectTaxonDeterminationOtuId,
  withAnatomicalPartCreation
} = useBiologicalAssociationAnatomicalParts({
  convertType,
  list,
  biologicalRelationship,
  relatedObject,
  flip,
  metadata: props.metadata,
  objectId: props.objectId,
  objectType: props.objectType,
  extendParams: EXTEND_PARAMS
})

watch(
  () => lock.relationship,
  (newVal) => {
    sessionStorage.setItem(STORAGE_KEYS.lockRelationship, newVal)
  }
)

watch(relatedObject, () => {
  if (canAutoSaveOnRelatedSelection.value) {
    saveAssociation()
  }
})

watch(listMode, (newVal) => {
  sessionStorage.setItem(STORAGE_KEYS.listMode, newVal)
  loadList()
})

onBeforeMount(() => {
  const relationshipLock = convertType(
    sessionStorage.getItem(STORAGE_KEYS.lockRelationship)
  )

  if (relationshipLock !== null) {
    lock.relationship = relationshipLock === true
  }

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

  loadList()

  // The withAnatomicalPartCreation watcher fires after session state is set, loading the AP mode list if
  // needed.
  loadAnatomicalPartSessionState()

  if (props.objectType === 'AnatomicalPart') {
    enableSubjectAnatomicalPart.value = false
  }
})

function storedListMode() {
  const value = sessionStorage.getItem(STORAGE_KEYS.listMode)

  return LIST_MODES.includes(value) ? value : LIST_MODES[0]
}

function listModeParams() {
  switch (listMode.value) {
    case 'Object':
      return {
        biological_association_object_id: props.objectId,
        biological_association_object_type: props.objectType
      }
    case 'Both':
      return { any_global_id: [props.metadata.annotation_target] }
    default:
      return {
        biological_association_subject_id: props.objectId,
        biological_association_subject_type: props.objectType
      }
  }
}

function loadList(page = 1) {
  BiologicalAssociation.where({
    ...listModeParams(),
    extend: EXTEND_PARAMS,
    recent: true,
    per: PER_PAGE,
    page
  }).then((response) => {
    list.value = response.body
    pagination.value = getPagination(response)
  })
}

function reset() {
  if (!lock.relationship) {
    biologicalRelationship.value = undefined
  }
  relatedObject.value = undefined
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

  // When deduplicating to an existing BA, omit subject/object id/type: those are
  // already set correctly on the matched record (possibly as AnatomicalPart) and
  // re-sending the form values (OTU/CO) would overwrite them incorrectly.
  const subjectObjectIds = createdBiologicalAssociation.value
    ? {}
    : flip.value
      ? {
          biological_association_object_id: props.objectId,
          biological_association_object_type: props.objectType,
          biological_association_subject_id: relatedObject.value.id,
          biological_association_subject_type: relatedObject.value.base_class
        }
      : {
          biological_association_object_id: relatedObject.value.id,
          biological_association_object_type: relatedObject.value.base_class,
          biological_association_subject_id: props.objectId,
          biological_association_subject_type: props.objectType
        }

  const payload = {
    biological_association: {
      ...subjectObjectIds,
      biological_relationship_id: biologicalRelationship.value.id,
      citations_attributes: citation.value ? [citation.value] : undefined,
      ...mapAnatomicalPartAttributesToAssociationSides()
    },
    extend: EXTEND_PARAMS
  }

  let targetId = createdBiologicalAssociation.value?.id

  if (!targetId && !withAnatomicalPartCreation.value) {
    const { body } = await BiologicalAssociation.where({
      biological_relationship_id: biologicalRelationship.value.id,
      ...subjectObjectIds
    })

    if (body.length) {
      targetId = body[0].id
    }
  }

  const saveRequest = targetId
    ? BiologicalAssociation.update(targetId, payload)
    : BiologicalAssociation.create(payload)

  saveRequest
    .then(({ body }) => {
      if (!enableSubjectAnatomicalPart.value) {
        addToList(body, { prepend: true })
      }
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

  relatedObject.value = {
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
    .list-mode-switch {
      flex-shrink: 0;
    }

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
