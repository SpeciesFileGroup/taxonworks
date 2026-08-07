<template>
  <h3>Collecting events</h3>
  <div class="flex-separate middle margin-medium-bottom">
    <ul class="context-menu no_bullets">
      <li>
        <VPagination
          :pagination="pagination.collectingEvents"
          @next-page="loadCollectingEvents($event.page)"
        />
      </li>
      <li v-if="ghostCount">
        <WarningGhost :count="ghostCount" />
      </li>
    </ul>
    <VPaginationCount
      :pagination="pagination.collectingEvents"
      v-model="collectingEventParams.per"
    />
  </div>

  <table class="table-striped full_width">
    <thead>
      <tr>
        <th>
          <input
            v-model="selectedAll"
            type="checkbox"
          />
        </th>
        <th>ID</th>
<!--        <th>Images</th>-->
        <th>DwC</th>
        <th class="half_width">Collecting Event</th>
        <th class="half_width">Verbatim collectors</th>
        <th />
      </tr>
    </thead>
    <tbody>
      <CollectingEventRow
        v-for="ce in list"
        :key="ce.id"
        v-model="selectedCEIds"
        :collecting-event="ce"
      />
    </tbody>
  </table>
</template>

<script setup>
import { computed, watch } from 'vue'
import useStore from '../../composables/useStore'
import VPagination from '@/components/pagination.vue'
import CollectingEventRow from './CollectingEventRow.vue'
import VPaginationCount from '@/components/pagination/PaginationCount.vue'
import WarningGhost from '../WarningGhost.vue'

const {
  collectingEvents,
  selectedCEIds,
  loadCollectingEvents,
  getPages,
  collectingEventParams,
  ghostCount
} = useStore()

const pagination = getPages()

const selectedAll = computed({
  get: () => collectingEvents.value.length === selectedCEIds.value.length,
  set: (value) => {
    selectedCEIds.value = value
      ? collectingEvents.value.map((ce) => ce.id)
      : []
  }
})

watch(
  () => collectingEventParams.value.per,
  () => {
    loadCollectingEvents(1)
  }
)

const list = computed(() =>
  collectingEvents.value.map((ce) => ({
    id: ce.id,
    object_tag: ce.object_tag,
    global_id: ce.global_id,
    verbatimCollector: ce.verbatim_collectors,
    // images: []
    // images: ce.determination_images.map((image) => adaptImage(image))
  }))
)

/* const adaptImage = (image) => ({
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
}) */
</script>
