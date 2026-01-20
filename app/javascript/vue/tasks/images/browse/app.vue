<template>
  <div class="flex-row gap-medium align-start margin-medium-top">
    <div class="panel">
      <TableDepicted :records="store.depictionObjects" />
    </div>
    <div class="panel full_width">
      <template v-if="store.image">
        <ViewerToolbar v-model="mode" />
        <ViewerImage
          v-model:mode="mode"
          :image-url="store.image.imageUrl"
          :image-height="store.image.height"
          :image-width="store.image.width"
          :pixels-to-centimeters="store.image.pixelsToCm"
          width="100%"
          :height="1080"
          :shapes="store.svgClips"
        />
      </template>
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
import ViewerToolbar from './components/Viewer/ViewerToolbar.vue'

const store = useStore()
const mode = ref('pan')

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
