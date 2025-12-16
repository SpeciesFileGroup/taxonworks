<template>
  <button
    class="button normal-input button-default"
    :disabled="!otuIds.length"
    @click="openImageMatrix"
  >
    View image matrix
  </button>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { LinkerStorage } from '@/shared/Filter/utils'

const MAX_URL_LENGTH = 2000

const props = defineProps({
  otuIds: {
    type: Array,
    default: () => []
  }
})

function openImageMatrix() {
  const ids = props.otuIds.join('|')
  const url = `${RouteNames.ImageMatrix}?otu_filter=${ids}`

  if (url.length > MAX_URL_LENGTH) {
    LinkerStorage.saveParameters({
      otu_id: ids
    })
    window.open(RouteNames.ImageMatrix, '_blank')
  } else {
    window.open(url, '_blank')
  }
}
</script>
