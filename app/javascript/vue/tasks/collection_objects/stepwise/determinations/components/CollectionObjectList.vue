<template>
  <h3>Collection objects</h3>
  <table class="full_width">
    <thead>
      <tr>
        <th>
          <input
            v-model="selectedAll"
            type="checkbox">
        </th>
        <th>ID</th>
        <th class="full_width">Object tag</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="co in collectionObjects">
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
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed, watch } from 'vue'
import useStore from '../composables/useStore'

const { 
  collectionObjects,
  selectedCOIds,
  selectedLabel,
  loadCollectionObjects
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
      loadCollectionObjects()
    }
  }
)


</script>