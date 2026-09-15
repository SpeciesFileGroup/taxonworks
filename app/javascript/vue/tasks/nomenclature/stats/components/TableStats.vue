<template>
  <div class="full_width">
    <VSpinner
      v-if="isSorting"
      full-screen
      legend="Loading..."
    />
    <table
      class="table-striped table-cell-border table-header-border full_width"
    >
      <thead>
        <tr>
          <template
            v-for="(header, index) in rankTable.column_headers"
            :key="header"
          >
            <th
              v-if="index >= HIDDEN_COLUMN_COUNT"
              class="cursor-pointer"
              @click="sortBy(header)"
            >
              <span v-html="header.replace('_', '<br>')" />
            </th>
          </template>
          <th
            class="cursor-pointer"
            @click="sortBy('cached')"
          >
            Show
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(row, index) in rankTable.data"
          :key="index"
          class="contextMenuCells"
        >
          <template
            v-for="(header, headerIndex) in rankTable.column_headers"
            :key="header"
          >
            <td v-if="headerIndex >= HIDDEN_COLUMN_COUNT">
              {{ row[headerIndex] }}
            </td>
          </template>
          <td>
            <a :href="browseUrlFor(valueFor('taxon_name_id', index))">
              {{ valueFor('cached', index) }}
            </a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { nextTick, ref, watch } from 'vue'
import { RouteNames } from '@/routes/routes'
import VSpinner from '@/components/ui/VSpinner.vue'

const HIDDEN_COLUMN_COUNT = 6

const props = defineProps({
  tableList: {
    type: Object,
    default: () => ({})
  }
})

const rankTable = ref({})
const isSorting = ref(false)
const ascending = ref(false)

watch(
  () => props.tableList,
  (newVal) => {
    withSpinner(() => {
      rankTable.value = newVal
    })
  },
  { deep: true, immediate: true }
)

function withSpinner(callback) {
  isSorting.value = true

  setTimeout(() => {
    callback()
    nextTick(() => {
      isSorting.value = false
    })
  }, 50)
}

function browseUrlFor(id) {
  return `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
}

function valueFor(header, rowIndex) {
  const index = rankTable.value.column_headers.findIndex(
    (item) => item === header
  )

  return rankTable.value.data[rowIndex][index]
}

function sortBy(header) {
  withSpinner(() => {
    const index = rankTable.value.column_headers.findIndex(
      (item) => item === header
    )

    rankTable.value.data.sort((a, b) =>
      ascending.value
        ? (a[index] === null) - (b[index] === null) ||
          +(a[index] > b[index]) ||
          -(a[index] < b[index])
        : (a[index] === null) - (b[index] === null) ||
          -(a[index] > b[index]) ||
          +(a[index] < b[index])
    )

    ascending.value = !ascending.value
  })
}
</script>
