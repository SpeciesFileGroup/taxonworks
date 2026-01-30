<template>
  <VNavbar
    class="margin-medium-top"
    @select="loadImage"
  />
  <div class="flex-row gap-medium align-start margin-medium-top">
    <template v-if="store.image">
      <ViewerToolbar
        v-if="store.image"
        v-model="mode"
      />
      <div class="panel full_width">
        <ViewerImage
          class="svg-viewer-container"
          v-model:mode="mode"
          :image-url="store.image.imageUrl"
          :image-height="store.image.height"
          :image-width="store.image.width"
          :pixels-to-centimeters="store.currentPixelsToCm"
          :shapes="store.svgClips"
        />
      </div>
      <div class="flex-col gap-medium">
        <PanelPixelToCm />
        <TableDepicted :records="store.depictionObjects" />
      </div>
    </template>
  </div>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { usePopstateListener } from '@/composables/usePopstateListener'
import { URLParamsToJSON } from '@/helpers'
import VNavbar from './components/Navbar.vue'
import ViewerImage from './components/Viewer/ViewerImage.vue'
import useStore from './store/store.js'
import TableDepicted from './components/Table/TableDepicted.vue'
import ViewerToolbar from './components/Viewer/ViewerToolbar.vue'
import PanelPixelToCm from './components/Panel/PanelPixelToCm.vue'

const store = useStore()
const mode = ref('pan')

function loadFromUrlParam() {
  const { image_id: imageId } = URLParamsToJSON(location.href)

  if (imageId) {
    loadImage(imageId)
  }
}

function loadImage(imageId) {
  store.load(imageId)
  store.loadDepictions(imageId)
}

usePopstateListener(loadFromUrlParam)
onBeforeMount(loadFromUrlParam)
</script>

<style scoped>
.svg-viewer-container {
  width: 100%;
  height: calc(100vh - 200px);
}
</style>
