<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th class="w-2">
          <input
            type="checkbox"
            v-model="selectAll"
          />
        </th>
        <th>Match</th>
        <th>Collection object</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="{ identifier, item } in list"
        :key="identifier"
      >
        <td>
          <input
            type="checkbox"
            :value="item.id"
            v-model="selectedIds"
          />
        </td>
        <td>{{ identifier }}</td>
        <td>
          <a
            :href="makeBrowseUrl({ id: item.id, type: COLLECTION_OBJECT })"
            v-html="item.object_tag"
          />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import { COLLECTION_OBJECT } from '@/constants'
import { makeBrowseUrl } from '@/helpers'

const props = defineProps({
  list: {
    type: Array,
    required: true
  }
})

const selectedIds = defineModel({
  type: Array,
  default: () => []
})

const selectAll = computed({
  get: () =>
    props.list.length && props.list.length === selectedIds.value.length,
  set: (value) => {
    selectedIds.value = value ? props.list.map(({ item }) => item.id) : []
  }
})
</script>
