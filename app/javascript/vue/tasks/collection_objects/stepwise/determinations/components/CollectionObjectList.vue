<template>
  <h3>Collection objects</h3>
  <VPagination
    :pagination="pagination.collectionObjects"
    @next-page="loadCollectionObjects($event.page)"
  />
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
        <th class="full_width">
          Object tag
        </th>
        <th />
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="co in collectionObjects"
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
        <td>
          <span v-html="co.object_tag" />
        </td>
        <td>
          <RadialNavigator :global-id="co.global_id" />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed, watch } from 'vue'
import useStore from '../composables/useStore'
import RadialNavigator from 'components/radials/navigation/radial.vue'
import VPagination from 'components/pagination.vue'

const {
  collectionObjects,
  selectedCOIds,
  selectedLabel,
  loadCollectionObjects,
  getPages
} = useStore()

const selectedAll = computed({
  get: () => collectionObjects.value.length === selectedCOIds.value.length,
  set: value => {
    selectedCOIds.value = value
      ? collectionObjects.value.map(co => co.id)
      : []
  }
})

watch(
  selectedLabel,
  label => {
    if (label) {
      loadCollectionObjects(1)
    }
  }
)

const pagination = getPages()

</script>
