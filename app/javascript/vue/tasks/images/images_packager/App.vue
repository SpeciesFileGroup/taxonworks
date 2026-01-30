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
import VSpinner from '@/components/ui/VSpinner.vue'
import {
  PackagerHeader,
  PackagerDownloads,
  PackagerTable,
  usePackager
} from '@/components/packager'
import { RouteNames } from '@/routes/routes.js'
import {
  STORAGE_FILTER_QUERY_KEY,
  STORAGE_FILTER_QUERY_STATE_PARAMETER
} from '@/constants'

const {
  isLoading,
  groups,
  items: images,
  errorMessage,
  filterParams,
  maxBytes,
  maxMb,
  refreshPreview,
  downloadGroup,
  goBackToFilter
} = usePackager({
  previewUrl: '/tasks/images/images_packager/preview.json',
  downloadUrl: '/tasks/images/images_packager/download',
  filterRoute: RouteNames.FilterImages,
  storageKey: STORAGE_FILTER_QUERY_KEY,
  storageStateParam: STORAGE_FILTER_QUERY_STATE_PARAMETER,
  payloadKey: 'images',
  loadErrorMessage: 'Unable to load images for packaging.'
})

const tableColumns = [
  { title: 'Image', slot: 'image' },
  { title: 'Dimensions', slot: 'dimensions' }
]

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
