<template>
  <div class="images-packager">
    <PackagerHeader
      v-if="!errorMessage"
      :max-bytes="maxBytes"
      filter-name="Filter images"
      :can-go-back="!!filterParams"
      @back="goBackToFilter"
    />

    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Preparing downloads..."
    />

    <div v-if="errorMessage && !isLoading">
      <p v-if="errorMessage === 'no-params'" class="feedback feedback-warning">
        No image filter parameters were found. Launch this task from
        <a :href="RouteNames.FilterImages">Filter Images</a>
        using the right side linker radial.
      </p>
      <p v-else class="feedback feedback-warning">{{ errorMessage }}</p>
    </div>

    <div v-if="!isLoading && !errorMessage">
      <PackagerDownloads
        :groups="groups"
        v-model:max-mb="maxMb"
        filename-prefix="images_download"
        item-label="images"
        item-count-key="image_ids"
        empty-message="No images found in the selection."
        @refresh="refreshPreview"
        @download="downloadGroup"
      />

      <PackagerTable
        title="Images"
        :items="images"
        :columns="tableColumns"
      >
        <template #image="{ item }">
          <span class="images-packager__cell">
            <template v-if="item.available">
              <a :href="`/images/${item.id}`" target="_blank">
                <img
                  :src="item.thumb_url"
                  :alt="item.name"
                  class="images-packager__thumb"
                  loading="lazy"
                />
              </a>
              <span>{{ item.name }}</span>
            </template>
            <span v-else class="unavailable">{{ item.name }} (unavailable)</span>
          </span>
        </template>
        <template #dimensions="{ item }">
          {{ item.width }}×{{ item.height }}
        </template>
      </PackagerTable>
    </div>
  </div>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import qs from 'qs'
import VSpinner from '@/components/ui/VSpinner.vue'
import {
  PackagerHeader,
  PackagerDownloads,
  PackagerTable
} from '@/components/packager'
import ajaxCall from '@/helpers/ajaxCall'
import { LinkerStorage } from '@/shared/Filter/utils'
import { RouteNames } from '@/routes/routes.js'
import {
  STORAGE_FILTER_QUERY_KEY,
  STORAGE_FILTER_QUERY_STATE_PARAMETER
} from '@/constants'
import { randomUUID } from '@/helpers'
import { createAndSubmitForm } from '@/helpers/forms'

const isLoading = ref(false)
const groups = ref([])
const images = ref([])
const errorMessage = ref('')
const filterParams = ref(null)
const maxBytes = ref(0)
const maxMb = ref(1000)

const tableColumns = [
  { title: 'Image', slot: 'image' },
  { title: 'Dimensions', slot: 'dimensions' }
]

function downloadGroup(index) {
  createAndSubmitForm({
    action: '/tasks/images/images_packager/download',
    data: {
      ...(filterParams.value || {}),
      group: index,
      max_mb: maxMb.value
    },
    openTab: true
  })
}

function goBackToFilter() {
  if (!filterParams.value) return

  const uuid = randomUUID()
  localStorage.setItem(
    STORAGE_FILTER_QUERY_KEY,
    JSON.stringify({ [uuid]: filterParams.value })
  )
  window.location.href = `${RouteNames.FilterImages}?${STORAGE_FILTER_QUERY_STATE_PARAMETER}=${uuid}`
}

function loadPreview(params) {
  isLoading.value = true
  errorMessage.value = ''

  ajaxCall('post', '/tasks/images/images_packager/preview.json', {
    ...params,
    max_mb: maxMb.value
  })
    .then(({ body }) => {
      images.value = body.images || []
      groups.value = body.groups || []
      filterParams.value = body.filter_params || null
      maxBytes.value = body.max_bytes || 0
    })
    .catch(() => {
      errorMessage.value = 'Unable to load images for packaging.'
    })
    .finally(() => {
      isLoading.value = false
    })
}

onBeforeMount(function () {
  const stored = LinkerStorage.getParameters() || {}
  const params = {
    ...qs.parse(window.location.search, {
      ignoreQueryPrefix: true,
      arrayLimit: 2000
    }),
    ...stored
  }

  LinkerStorage.removeParameters()

  if (!Object.keys(params).length) {
    errorMessage.value = 'no-params'
    return
  }

  loadPreview(params)
})

function refreshPreview() {
  if (!filterParams.value) return
  loadPreview(filterParams.value)
}
</script>

<style scoped>
.images-packager__cell {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.images-packager__thumb {
  width: 40px;
  height: 40px;
  object-fit: contain;
  background: #f5f5f5;
  border-radius: 2px;
}

.unavailable {
  color: var(--text-muted-color);
  font-style: italic;
}
</style>
