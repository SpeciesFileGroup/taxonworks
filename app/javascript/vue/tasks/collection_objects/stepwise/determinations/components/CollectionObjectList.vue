<template>
  <h3>Collection objects</h3>
  <div class="flex-separate">
    <VPagination
      :pagination="pagination.collectionObjects"
      @next-page="loadCollectionObjects($event.page)"
    />
    <label>
      <input
        type="checkbox"
        @change="toggleImages"
      >
      Show images
    </label>
  </div>

  <table class="full_width">
    <thead>
      <tr>
        <th>
          <input
            v-model="selectedAll"
            type="checkbox"
          >
        </th>
        <th>ID</th>
        <th v-if="isImageColumnVisible">
          Images
        </th>
        <th class="full_width">
          Object tag
        </th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="co in list"
        :key="co.id"
      >
        <td>
          <input
            v-model="selectedCOIds"
            :value="co.id"
            type="checkbox"
          >
        </td>
        <td>
          {{ co.id }}
        </td>
        <td v-if="isImageColumnVisible">
          <ImageViewer
            v-for="image in co.images"
            :key="image.image_id"
            :image="image"
            :edit="false"
          />
        </td>
        <td>
          <span v-html="co.object_tag" />
        </td>
        <td>
          <RadialNavigator :global-id="co.global_id" />
        </td>
      </tr>
    </tbody>
    <VSpinner
      v-if="isLoading"
      full-screen
    />
  </table>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import useStore from '../composables/useStore'
import RadialNavigator from 'components/radials/navigation/radial.vue'
import VPagination from 'components/pagination.vue'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import VSpinner from 'components/spinner.vue'

const {
  collectionObjects,
  selectedCOIds,
  selectedLabel,
  loadCollectionObjects,
  getPages
} = useStore()

const pagination = getPages()

const selectedAll = computed({
  get: () => collectionObjects.value.length === selectedCOIds.value.length,
  set: value => {
    selectedCOIds.value = value
      ? collectionObjects.value.map(co => co.id)
      : []
  }
})

const isImageColumnVisible = ref(false)
const isLoading = ref(false)

const toggleImages = e => {
  const newValue = e.target.checked

  isLoading.value = !!list.value.length

  setTimeout(() => {
    isImageColumnVisible.value = newValue
    isLoading.value = false
  }, 100)
}

watch(
  selectedLabel,
  label => {
    if (label) {
      loadCollectionObjects(1)
    }
  }
)

const list = computed(() => collectionObjects.value.map(co => ({
  id: co.id,
  object_tag: co.object_tag,
  global_id: co.global_id,
  images: co.determination_images.map(image => adaptImage(image))
})))

const adaptImage = image => ({
  id: image.image_id,
  alternatives: {
    thumb: {
      image_file_url: image.thumbnail
    },
    medium: {
      image_file_url: image.large
    }
  },
  image_file_url: image.large
})

</script>
