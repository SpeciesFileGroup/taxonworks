<template>
  <div class="biological_relationships_annotator">
    <BiologicalAssociationForm
      ref="biologicalAssociationFormRef"
      button-color="create"
      citation-lock
      @add="saveAssociation"
    />

    <TableList
      class="separate-top"
      :list="list"
      :metadata="metadata"
      @edit="(ba) => biologicalAssociationFormRef.setBiologicalAssociation(ba)"
      @delete="removeItem"
    />
  </div>
</template>

<script setup>
import { watch, onBeforeMount, reactive, useTemplateRef } from 'vue'
import { useSlice } from '@/components/radials/composables'
import { BiologicalAssociation } from '@/routes/endpoints'
import TableList from './table.vue'
import BiologicalAssociationForm from '@/components/Form/FormBiologicalAssociation/BiologicalAssociation.vue'

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

const biologicalAssociationFormRef = useTemplateRef(
  'biologicalAssociationFormRef'
)

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

function makeCitation(data) {
  return {
    id: data.id,
    source_id: data.source_id,
    label: data.object_label,
    pages: data.pages
  }
}

function makeBA(item) {
  const citation = makeCitation(item.citations[0] || {})

  return {
    id: item.id,
    globalId: item.global_id,
    related: item.object,
    relationship: {
      id: item.biological_relationship_id,
      ...item.biological_relationship
    },
    citation
  }
}

onBeforeMount(() => {
  BiologicalAssociation.where({
    biological_association_subject_id: props.objectId,
    biological_association_subject_type: props.objectType,
    extend: EXTEND_PARAMS
  }).then(({ body }) => {
    list.value = body.map(makeBA)
  })
})

function saveAssociation(ba) {
  const payload = {
    biological_association: {
      biological_association_subject_id: props.objectId,
      biological_association_subject_type: props.objectType,
      biological_association_object_id: ba.related.id,
      biological_association_object_type: ba.related.base_class,
      biological_relationship_id: ba.relationship.id,
      citations_attributes: ba.citation.source_id ? [ba.citation] : undefined
    },
    extend: EXTEND_PARAMS
  }

  const saveRequest = ba.id
    ? BiologicalAssociation.update(ba.id, payload)
    : BiologicalAssociation.create(payload)

  saveRequest
    .then(({ body }) => {
      addToList(makeBA(body))
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
