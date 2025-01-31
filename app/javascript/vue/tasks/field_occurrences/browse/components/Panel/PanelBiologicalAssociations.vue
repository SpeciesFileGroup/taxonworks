<template>
  <PanelContainer title="Biological associations">
    <ListITems
      class="no_bullets"
      :list="biologicalAssociations"
      label="object_tag"
      :remove="false"
    />
  </PanelContainer>
</template>

<script setup>
import { ref, watch } from 'vue'
import { BiologicalAssociation } from '@/routes/endpoints'
import PanelContainer from './PanelContainer.vue'
import ListITems from '@/components/displayList.vue'

const props = defineProps({
  objectId: {
    type: [String, undefined],
    required: true
  },

  objectType: {
    type: [String, undefined],
    required: true
  }
})

const list = ref([])

watch(
  () => props.objectId,
  (id) => {
    list.value = []

    if (id) {
      BiologicalAssociation.where({
        biological_association_subject_id: props.objectId,
        biological_association_subject_type: props.objectType
      })
        .then(({ body }) => {
          list.value = body
        })
        .catch(() => {})
    }
  }
)
</script>
