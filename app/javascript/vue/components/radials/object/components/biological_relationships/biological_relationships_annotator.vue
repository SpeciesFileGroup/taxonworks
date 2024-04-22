<template>
  <div class="biological_relationships_annotator">
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
        Choose related OTU/collection object
      </h3>
    </div>
    <biological
      v-if="!biologicalRelationship"
      class="separate-bottom"
      @select="setBiologicalRelationship"
    />
    <related
      v-if="!biologicalRelation"
      class="separate-bottom separate-top"
      @select="biologicalRelation = $event"
    />

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
      class="separate-top"
      :list="list"
      :metadata="metadata"
      @edit="editBiologicalRelationship"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import Biological from './biological.vue'
import Related from './related.vue'
import TableList from './table.vue'
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
import { ref, computed, watch, onBeforeMount, reactive } from 'vue'
import { useSlice } from '@/components/radials/composables'

const EXTEND_PARAMS = [
  'origin_citation',
  'object',
  'subject',
  'biological_relationship',
  'citations',
  'source'
]

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
  }
})

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const validateFields = computed(
  () => biologicalRelationship.value && biologicalRelation.value
)

const displayRelated = computed(() => {
  return (
    biologicalRelation.value?.object_tag || biologicalRelation.value?.label_html
  )
})

const createdBiologicalAssociation = computed(() =>
  list.value.find(
    (item) =>
      item.biological_relationship_id === biologicalRelationship.value?.id &&
      item.biological_association_object_id === biologicalRelation.value?.id
  )
)

const biologicalRelationLabel = computed(
  () =>
    biologicalRelationship.value?.label || biologicalRelationship.value?.name
)

const biologicalRelation = ref()
const biologicalRelationship = ref()
const citation = ref(makeEmptyCitation())
const flip = ref(false)

const lock = reactive({
  source: false,
  relationship: false
})

watch(
  () => lock.relationship,
  (newVal) => {
    sessionStorage.setItem('radialObject::biologicalRelationship::lock', newVal)
  }
)

watch(biologicalRelation, (newVal) => {
  if (
    newVal?.id &&
    citation.value.source_id &&
    biologicalRelationship.value?.id
  ) {
    saveAssociation()
  }
})

onBeforeMount(() => {
  const value = convertType(
    sessionStorage.getItem('radialObject::biologicalRelationship::lock')
  )
  if (value !== null) {
    lock.relationship = value === true
  }

  if (lock.relationship) {
    const relationshipId = convertType(
      sessionStorage.getItem('radialObject::biologicalRelationship::id')
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
    extend: EXTEND_PARAMS
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
  citation.value = {
    ...makeEmptyCitation(),
    source_id: lock.source ? citation.value.source_id : undefined,
    pages: lock.source ? citation.value.pages : undefined
  }
}

function saveAssociation() {
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
      citations_attributes: citation.value ? [citation.value] : undefined
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
      reset()
      TW.workbench.alert.create(
        'Biological association was successfully saved.',
        'notice'
      )
    })
    .catch(() => {})
}

function removeItem(item) {
  BiologicalAssociation.destroy(item.id).then(() => {
    removeFromList(item)
  })
}

function setCitation(citation) {
  citation.value = {
    id: citation.id,
    pages: citation.pages,
    source_id: citation.source_id,
    is_original: citation.is_original
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
  sessionStorage.setItem('radialObject::biologicalRelationship::id', item.id)
}

function unsetBiologicalRelationship() {
  biologicalRelationship.value = undefined
  flip.value = false
}
</script>
<style lang="scss">
.radial-annotator {
  .biological_relationships_annotator {
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
  }
}
</style>
