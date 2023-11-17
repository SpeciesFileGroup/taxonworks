<template>
  <div>
    <spinner-component
      full-screen
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isLoading || isSaving"
    />
    <h1>Free form</h1>
    <nav-bar />
    <template v-if="imageStore.image">
      <div class="horizontal-left-content align-start">
        <div
          class="horizontal-left-content align-start"
          style="width: 50%"
        >
          <DrawControls class="margin-medium-right" />
          <DrawBoard
            v-if="imageStore.image"
            :image="imageStore.image"
          />
        </div>
        <div
          class="margin-medium-left"
          style="width: 50%"
        >
          <div class="flex-separate margin-large-top">
            <div class="full_width">
              <spinner-component
                v-if="disabledPanel && view == 'Assign'"
                :show-legend="false"
                :show-spinner="false"
              />
              <component :is="componentSelected" />
            </div>
            <summary-component
              v-if="view != 'Review'"
              class="full_width margin-medium-left"
            />
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
import DrawControls from './components/DrawBoard/DrawControls.vue'

import SwitchComponent from '@/components/switch'
import AssignComponent from './components/Assign/Main'
import UploadImage from './components/UploadImage'
import ReviewComponent from './components/Review'
import SummaryComponent from './components/Summary'
import SpinnerComponent from '@/components/spinner'
import NavBar from './components/NavBar'
import useImageStore from './store/image.js'

const TABS = {
  Assign: AssignComponent,
  Review: ReviewComponent
}

const imageStore = useImageStore()

const disabledPanel = computed(() => {
  return false
})

const componentSelected = computed(() => TABS[view.value])
const isLoading = ref(false)
const isSaving = ref(false)
const view = ref('Assign')

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const coId = urlParams.get('collection_object_id')

  loadImage(1044784)

  /*   if (coId && /^\d+$/.test(coId)) {
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
