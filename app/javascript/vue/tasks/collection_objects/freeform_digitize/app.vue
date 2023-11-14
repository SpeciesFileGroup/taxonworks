<template>
  <div>
    <spinner-component
      full-screen
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isLoading || isSaving"
    />
    <h1>Free form</h1>
    <nav-bar />
    <template v-if="image">
      <div class="horizontal-left-content align-start">
        <div
          class="horizontal-left-content align-start"
          style="width: 50%"
        >
          <DrawControls class="margin-medium-right" />
          <DrawBoard
            v-if="image"
            :image="image"
          />
        </div>
        <div
          class="margin-medium-left"
          style="width: 50%"
        >
          <switch-component
            v-model="view"
            :options="Object.keys(TABS)"
          />
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
              @update="createSled"
              @update-new="createSled(true)"
              @update-next="createSled(true, $event)"
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
import OverviewMetadataComponent from './components/Overview'
import SummaryComponent from './components/Summary'
import SpinnerComponent from '@/components/spinner'
import NavBar from './components/NavBar'
import useStore from './store/store.js'

const TABS = {
  /*   Assign: AssignComponent,
  'Overview metadata': OverviewMetadataComponent,
  Review: ReviewComponent */
}

const store = useStore()

const disabledPanel = computed(() => {
  return false
})

const componentSelected = computed(() => TABS[view.value])
const image = computed({
  get: () => store.image,
  set: (value) => (store.image = value)
})

const isLoading = ref(false)
const isSaving = ref(false)
const fileImage = ref()

const view = ref('Assign')

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const coId = urlParams.get('collection_object_id')

  /*   if (coId && /^\d+$/.test(coId)) {
  } */
})

function loadImage(imageId) {
  isLoading.value = true
  ImageService.find(imageId)
    .then((response) => {
      const ajaxRequest = new XMLHttpRequest()

      image.value = response.body
      ajaxRequest.open('GET', response.body.image_display_url)
      ajaxRequest.responseType = 'blob'
      ajaxRequest.onload = () => {
        const blob = ajaxRequest.response
        const fr = new FileReader()

        fr.onloadend = () => {
          const dataUrl = fr.result
          const image = new Image()

          image.onload = () => {
            fileImage.value = dataUrl
            isLoading.value = false
          }

          image.src = dataUrl
        }
        fr.readAsDataURL(blob)
      }
      ajaxRequest.send()
    })
    .finally(() => {
      isLoading.value = false
    })
}
</script>
