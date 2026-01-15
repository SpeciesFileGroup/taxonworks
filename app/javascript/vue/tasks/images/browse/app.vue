<template>
  <div class="flex-row gap-medium align-start margin-medium-top">
    <div class="panel">
      <TableDepicted :records="store.depictionObjects" />
    </div>
    <div class="panel">
      <ViewerImage
        v-if="store.image"
        :image-url="store.image.imageUrl"
        :pixels-to-centimeters="pixelsToCentimeters"
        :width="1920"
        :height="1080"
      />
    </div>
  </div>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { usePopstateListener } from '@/composables/usePopstateListener'
import { URLParamsToJSON } from '@/helpers'
import ViewerImage from './components/Viewer/ViewerImage.vue'
import useStore from './store/store.js'
import TableDepicted from './components/Table/TableDepicted.vue'

const pixelsToCentimeters = 37

const store = useStore()

function loadFromUrlParam() {
  const { image_id: imageId } = URLParamsToJSON(location.href)

  if (imageId) {
    store.load(imageId)
    store.loadDepictions(imageId)
  }
}

usePopstateListener(loadFromUrlParam)
onBeforeMount(loadFromUrlParam)
</script>
