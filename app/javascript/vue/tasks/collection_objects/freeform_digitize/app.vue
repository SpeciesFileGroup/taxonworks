<template>
  <div>
    <spinner-component
      full-screen
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isLoading || isSaving"
    />
    <h1>Free form</h1>

    <template v-if="imageStore.image">
      <NavBar />
      <div class="horizontal-left-content align-start">
        <div class="horizontal-left-content align-start full_width">
          <DrawBoard
            v-if="imageStore.image"
            :image="imageStore.image"
            class="full_width full_height"
          />
        </div>
        <div class="right-panel">
          <summary-component class="full_width" />
          <VSwitch
            :options="Object.keys(TABS)"
            v-model="view"
          />
          <div class="flex-separate">
            <div class="full_width">
              <spinner-component
                v-if="!!store.collectionObject.id && view == 'Assign'"
                :show-legend="false"
                :show-spinner="false"
              />
              <component :is="componentSelected" />
            </div>
          </div>
        </div>
      </div>
    </template>
    <upload-image
      class="full_width margin-large-top"
      v-else
      @created="loadImage($event.id)"
    />
  </div>
</template>

<script setup>
import { Image as ImageService } from '@/routes/endpoints'
import { computed, ref, onBeforeMount } from 'vue'
import DrawBoard from './components/DrawBoard/DrawBoard.vue'
import VSwitch from '@/components/switch'
import AssignComponent from './components/Assign/Main'
import UploadImage from './components/UploadImage'
import ReviewComponent from './components/Review.vue'
import SpinnerComponent from '@/components/spinner'
import useImageStore from './store/image.js'
import useStore from './store/store'
import NavBar from './components/NavBar.vue'

const TABS = {
  Assign: AssignComponent,
  Review: ReviewComponent
}

const store = useStore()
const imageStore = useImageStore()

const componentSelected = computed(() => TABS[view.value])
const isLoading = ref(false)
const isSaving = ref(false)
const view = ref('Assign')

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const imageId = urlParams.get('image_id')

  //loadImage(1044784)

  /*   if (/^\d+$/.test(imageId)) {
  } */
})

function loadImage(imageId) {
  isLoading.value = true
  ImageService.find(imageId)
    .then((response) => {
      imageStore.image = response.body
    })
    .finally(() => {
      isLoading.value = false
    })
}
</script>

<style scoped>
.right-panel {
  max-width: 500px;
  width: 500px;
}
</style>
