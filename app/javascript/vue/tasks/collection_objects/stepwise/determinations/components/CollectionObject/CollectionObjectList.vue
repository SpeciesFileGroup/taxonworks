<template>
  <h3>Collection objects</h3>
  <div class="flex-separate middle margin-medium-bottom">
    <ul class="context-menu no_bullets">
      <li>
        <VPagination
          :pagination="pagination.collectionObjects"
          @next-page="loadCollectionObjects($event.page)"
        />
      </li>
      <li v-if="ghostCount">
        <WarningGhost :count="ghostCount" />
      </li>
    </ul>
    <VPaginationCount
      :pagination="pagination.collectionObjects"
      v-model="collectionObjectParams.per"
    />
  </div>

  <table class="table-striped full_width">
    <thead>
      <tr>
        <th>
          <input
            v-model="selectedAll"
            type="checkbox"
          >
        </th>
        <th>ID</th>
        <th>
          Images
        </th>
        <th>DwC</th>
        <th class="full_width">
          Object tag
        </th>
        <th />
      </tr>
    </thead>
    <tbody>
      <CollectionObjectRow
        v-for="co in list"
        :key="co.id"
        v-model="selectedCOIds"
        :collection-object="co"
      />
    </tbody>
  </table>
</template>

<script setup>
import { computed, watch } from 'vue'
import useStore from '../../composables/useStore'
import VPagination from 'components/pagination.vue'
import CollectionObjectRow from './CollectionObjectRow.vue'
import VPaginationCount from 'components/pagination/PaginationCount.vue'
import WarningGhost from '../WarningGhost.vue'

const {
  collectionObjects,
  selectedCOIds,
  loadCollectionObjects,
  getPages,
  collectionObjectParams,
  ghostCount
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

watch(
  () => collectionObjectParams.value.per,
  () => {
    loadCollectionObjects(1)
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
