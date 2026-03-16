<template>
  <div class="margin-medium-top">
    <spinner-component
      full-screen
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isLoading || isSaving"
    />

    <NavBar>
      <div class="full_width flex-separate middle">
        <DrawControls
          v-if="imageStore.image"
          v-show="view === 0"
        />
        <div class="horizontal-right-content gap-small">
          <template v-if="imageStore.image">
            <SaveButtons />
            <VBtn
              color="primary"
              medium
              @click="openTask"
            >
              Change image
            </VBtn>
          </template>
          <RecentButton />
        </div>
      </div>
    </NavBar>
    <template v-if="imageStore.image">
      <div class="horizontal-left-content align-start gap-medium">
        <DrawBoard
          v-show="view === 0"
          :image="imageStore.image"
        />
        <LayerViewer v-if="view === 1" />
        <div class="right-panel">
          <VSwitch
            :options="tabMenu"
            use-index
            v-model="view"
          />
          <div class="flex-separate">
            <div class="full_width">
              <spinner-component
                v-if="!!store.collectionObject.id && view === 0"
                :show-legend="false"
                :show-spinner="false"
              />
              <component :is="componentSelected" />
            </div>
          </div>
        </div>
      </div>
    </template>
    <UploadImage
      v-else
      class="margin-medium-top"
      @created="(e) => loadImage(e.id)"
    />
  </div>
</template>

<script setup>
import { computed, ref, onBeforeMount } from 'vue'
import VSwitch from '@/components/ui/VSwitch'
import AssignComponent from './components/Assign/Main'
import UploadImage from './components/UploadImage'
import ReviewComponent from './components/Review.vue'
import SpinnerComponent from '@/components/ui/VSpinner'
import useImageStore from './store/image.js'
import useStore from './store/store'
import NavBar from '@/components/layout/NavBar.vue'
import LayerViewer from './components/LayerViewer.vue'
import DrawBoard from './components/DrawBoard/DrawBoard.vue'
import DrawControls from './components/DrawBoard/DrawControls.vue'
import SaveButtons from './components/SaveButtons.vue'
import RecentButton from './components/Recent.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { RouteNames } from '@/routes/routes'

const TABS = [AssignComponent, ReviewComponent]

defineOptions({
  name: 'FreeformDigitizeApp'
})

const store = useStore()
const imageStore = useImageStore()

const isLoading = ref(false)
const isSaving = ref(false)
const view = ref(0)

const componentSelected = computed(() => TABS[view.value])
const tabMenu = computed(() => [
  'Assign',
  `Review (${store.collectionObjects.length})`
])

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const imageId = urlParams.get('image_id')

  if (/^\d+$/.test(imageId)) {
    loadImage(imageId)
  }
})

async function loadImage(imageId) {
  isLoading.value = true
  try {
    await imageStore.loadImage(imageId)
    await store.loadReport(imageId)
  } catch (e) {}
  isLoading.value = false
}

function openTask() {
  window.open(RouteNames.FreeFormTask)
}
</script>

<style scoped>
.right-panel {
  max-width: 500px;
  width: 500px;
}
</style>
