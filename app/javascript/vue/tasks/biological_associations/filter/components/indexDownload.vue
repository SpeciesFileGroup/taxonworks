<template>
  <slot :action="download" />
</template>

<script setup>
import { createAndSubmitForm } from '@/helpers'

const props = defineProps({
  params: {
    type: Object,
    required: true
  },

  selectedIds: {
    type: Array,
    default: () => []
  }
})

function download() {
  const data = props.selectedIds.length
    ? { biological_association_id: props.selectedIds }
    : props.params

  createAndSubmitForm({
    action: '/tasks/biological_associations/filter/download_index',
    data
  })
}
</script>
