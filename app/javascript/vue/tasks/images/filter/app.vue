<template>
  <div>
    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
    />
    <div class="flex-separate middle">
      <h1>Filter images</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeFilter"
            >
            Show filter
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeJSONRequest"
            >
            Show JSON Request
          </label>
        </li>
      </ul>
    </div>
    <div
      v-show="activeJSONRequest"
      class="panel content separate-bottom"
    >
      <div class="flex-separate middle">
        <span>
          JSON Request: {{ urlRequest }}
        </span>
      </div>
    </div>

    <div class="horizontal-left-content align-start">
      <FilterComponent
        class="separate-right"
        v-show="preferences.activeFilter"
        @parameters="makeFilterRequest"
        @reset="resetFilter"
      />
      <div class="full_width">
        <div
          class="flex-separate margin-medium-bottom"
          :class="{ 'separate-left': activeFilter }"
        >
          <PaginationComponent
            v-if="pagination && list.length"
            :pagination="pagination"
            @next-page="loadPage"
          />
          <div
            v-if="list.length"
            class="horizontal-left-content"
          >
            <span class="horizontal-left-content">{{ list.length }} records.</span>
            <div class="margin-small-left">
              <select v-model="per">
                <option
                  v-for="records in maxRecords"
                  :key="records"
                  :value="records"
                >
                  {{ records }}
                </option>
              </select>
              records per page.
            </div>
          </div>
        </div>
        <div
          :class="{ 'separate-left': activeFilter }"
        >
          <div class="panel content margin-medium-bottom">
            <div class="horizontal-left-content">
              <TagAll
                type="Image"
                :ids="idsSelected"
              />
              <AttributionComponent
                class="margin-small-left margin-small-right"
                :ids="idsSelected"
                type="Image"
              />
              <span>|</span>
              <div class="margin-small-left">
                <SelectAll
                  v-model="selectedIds"
                  :ids="list.map(({id}) => id)"
                />
              </div>
            </div>
          </div>
          <ListComponent
            v-model="selectedIds"
            :list="list"
          />
          <h2
            v-if="alreadySearch && !list.length"
            class="subtle middle horizontal-center-content no-found-message"
          >
            No records found.
          </h2>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>

import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import PaginationComponent from 'components/pagination'
import PlatformKey from 'helpers/getPlatformKey'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import SelectAll from 'tasks/collection_objects/filter/components/selectAll.vue'
import AttributionComponent from './components/attributions/main.vue'
import VSpinner from 'components/spinner.vue'
import useFilter from 'tasks/people/filter/composables/useFilter.js'

import { Image } from 'routes/endpoints'
import { reactive, ref } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const selectedIds = ref([])

const preferences = reactive({
  activeFilter: true,
  activeJSONRequest: false
})

const {
  isLoading,
  list,
  pagination,
  per,
  urlRequest,
  loadPage,
  makeFilterRequest,
  resetFilter
} = useFilter(Image)

const urlParams = URLParamsToJSON(location.href)

if (Object.keys(urlParams).length) {
  makeFilterRequest(urlParams)
}

TW.workbench.keyboard.createLegend(`${PlatformKey()}+f`, 'Search', 'Filter images')
TW.workbench.keyboard.createLegend(`${PlatformKey()}+r`, 'Reset task', 'Filter images')

</script>

<script>
export default {
  name: 'FilterImages'
}
</script>

<style scoped>
  .no-found-message {
    height: 70vh;
  }
</style>

<style scoped>
  .no-found-message {
    height: 70vh;
  }
</style>
