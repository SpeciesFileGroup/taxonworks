<template>
  <VNavbar
    class="margin-medium-top"
    @select="loadImage"
  />
  <VSpinner
    v-if="isLoading"
    full-screen
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
          :layers="store.layers"
        />
      </div>
      <div class="flex-col gap-medium right-column overflow-y-auto">
        <PanelPixelToCm />
        <PanelDepictions />
        <PanelExif :image-url="store.image.imageUrl" />
      </div>
    </template>
  </div>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { usePopstateListener } from '@/composables/usePopstateListener'
import { setParam, URLParamsToJSON } from '@/helpers'
import VSpinner from '@/components/ui/VSpinner.vue'
import VNavbar from './components/Navbar.vue'
import ViewerImage from './components/Viewer/ViewerImage.vue'
import useStore from './store/store.js'
import ViewerToolbar from './components/Viewer/ViewerToolbar.vue'
import PanelPixelToCm from './components/Panel/PanelPixelToCm.vue'
import PanelExif from './components/Panel/PanelExif.vue'
import PanelDepictions from './components/Panel/PanelDepictions.vue'
import { RouteNames } from '@/routes/routes'

const store = useStore()
const mode = ref('pan')
const isLoading = ref(false)

function loadFromUrlParam() {
  const { image_id: imageId } = URLParamsToJSON(location.href)

  if (imageId) {
    loadImage(imageId)
  }
}

function loadImage(imageId) {
  isLoading.value = true

  store.$reset()

  Promise.all([store.load(imageId), store.loadDepictions(imageId)])
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
      setParam(RouteNames.BrowseImage, 'image_id', imageId)
    })
}

usePopstateListener(loadFromUrlParam)
onBeforeMount(loadFromUrlParam)
</script>

<style scoped>
.right-column {
  width: 100%;
  max-width: 440px;
  height: calc(100vh - 180px);
}

.svg-viewer-container {
  width: 100%;
  height: calc(100vh - 180px);
  max-height: calc(100vh - 180px);
}
</style>
