<template>
  <div>
    <spinner-component
      v-if="isLoading"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
    />
    <div class="flex-separate middle">
      <h1>Filter extracts</h1>
      <menu-preferences v-model="preferences"/>
    </div>

    <div
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom">
      <div class="flex-separate middle">
        <span>
          JSON Request: {{ urlRequest }}
        </span>
      </div>
    </div>

    <div class="horizontal-left-content align-start">
      <filter-component
        class="separate-right"
        v-show="preferences.activeFilter"
        @parameters="makeFilterRequest"
        @reset="resetTask"/>
      <div class="full_width overflow-x-auto">
        <div
          v-if="recordsFound"
          class="horizontal-left-content flex-separate separate-bottom">
          <div class="horizontal-left-content">
            <span class="separate-left separate-right">|</span>
            <csv-button
              :url="urlRequest"
              :options="{ fields: csvFields }"/>
            <dwc-download
              class="margin-small-left"
              :params="$refs.filterComponent.parseParams"
              :total="pagination.total"/>
            <dwc-reindex
              class="margin-small-left"
              :params="$refs.filterComponent.parseParams"
              :total="pagination.total"
            />
          </div>
        </div>

        <div
          class="flex-separate margin-medium-bottom"
          v-if="pagination"
        >
          <pagination-component
            :pagination="pagination"
            @next-page="loadPage"
          />
          <pagination-count
            v-model="per"
            :pagination="pagination"
          />
        </div>

        <list-component
          v-if="list.length"
          :list="list"
        />
        <h2
          v-if="!list.length"
          class="subtle middle horizontal-center-content no-found-message"
        >
          No records found.
        </h2>
      </div>
    </div>
  </div>
</template>

<script setup>

import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvButton from './components/csvDownload'
import PaginationComponent from 'components/pagination'
import PaginationCount from 'components/pagination/PaginationCount'
import MenuPreferences from './components/MenuPreferences.vue'
import { Extract } from 'routes/endpoints'
import useFilter from './composables/useFilter.js'
import { computed, ref, reactive } from 'vue'

const csvFields = computed(() =>
  list.value.map((item, index) =>
    ({
      label: item,
      value: (row, field) => row[index] || field.default,
      default: ''
    })
  )
)

const {
  isLoading,
  list,
  per,
  pagination,
  makeFilterRequest,
  resetFilter
} = useFilter(Extract)

const preferences = reactive({
  activeFilter: true,
  activeJSONRequest: false
})

const alreadySearch = ref(false)

const resetTask = () => {
  resetFilter()
  history.pushState(null, null, '/tasks/extracts/filter')
}
</script>

<style scoped>
  .no-found-message {
    height: 70vh;
  }
</style>
