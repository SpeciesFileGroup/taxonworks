<template>
  <PanelContainer title="Identifiers">
    <TableAttributes
      :header="['Identifier', 'On']"
      :items="identifiers"
    />
  </PanelContainer>
</template>

<script setup>
import { Identifier } from '@/routes/endpoints'
import { computed, ref, watch } from 'vue'
import PanelContainer from './PanelContainer.vue'
import TableAttributes from '@/tasks/collection_objects/browse/components/Table/TableAttributes.vue'

const props = defineProps({
  objectId: {
    type: [Number, undefined],
    required: true
  },

  objectType: {
    type: [String, undefined],
    required: true
  }
})

const identifiers = ref([])

watch(
  () => props.objectId,
  (id) => {
    identifiers.value = []

    if (id) {
      Identifier.where({
        identifier_object_id: props.objectId,
        identifier_object_type: props.objectType
      })
        .then(({ body }) => {
          identifiers.value = body
        })
        .catch(() => {})
    }
  }
)
</script>
