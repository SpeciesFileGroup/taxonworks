<template>
  <slot :action="downloadTsv" />
</template>

<script setup>
import { computed } from 'vue'
import { createAndSubmitForm } from '@/helpers'

const props = defineProps({
  params: {
    type: Object,
    default: undefined
  },

  pagination: {
    type: Object,
    default: undefined
  },

  selectedList: {
    type: Array,
    default: () => []
  }
})

const payload = computed(() => {
  const params = props.selectedList.length
    ? { content_id: props.selectedList }
    : props.params

  return {
    ...params,
    per: props.pagination?.total
  }
})

function downloadTsv() {
  createAndSubmitForm({
    action: '/tasks/content/filter/download',
    data: payload.value
  })
}
</script>
