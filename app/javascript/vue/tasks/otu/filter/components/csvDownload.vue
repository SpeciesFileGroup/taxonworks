<template>
  <slot :action="downloadCSV" />
</template>

<script setup>
import { createAndSubmitForm } from '@/helpers'

const props = defineProps({
  params: {
    type: Object,
    required: true
  }
})

function downloadCSV() {
  createAndSubmitForm({
    action: '/tasks/otus/filter/download',
    data: props.params
  })
}
</script>
