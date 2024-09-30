<template>
  <ButtonImageMatrix
    class="button normal-input button-default"
    :disabled="!ids.length"
    @click="() => openImageMatrix(ids)"
  />
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import ButtonImageMatrix from '@/tasks/observation_matrices/dashboard/components/buttonImageMatrix.vue'

defineProps({
  ids: {
    type: Object,
    required: true
  }
})

function openImageMatrix(ids) {
  window.open(
    `${RouteNames.ImageMatrix}?otu_filter=${ids.join('|')}&view=true`,
    '_blank'
  )
}
</script>
