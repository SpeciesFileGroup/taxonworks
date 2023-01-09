
<template>
  <div>
    <div class="flex-separate middle">
      <h1>Filter images</h1>
      <FilterSettings
        v-model:filter="preferences.activeFilter"
        v-model:url="preferences.activeJSONRequest"
        v-model:append="append"
        v-model:list="preferences.showList"
      />
    </div>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <FilterLayout
      :filter="preferences.activeFilter"
      :table="preferences.showList"
      :pagination="pagination"
      :object-type="IMAGE"
      v-model:per="per"
      :parameters="parameters"
      @filter="makeFilterRequest()"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <div
          v-if="list.length"
          class="horizontal-right-content"
        >
          <TagAll
            type="Image"
            :ids="selectedIds"
          />
          <AttributionComponent
            class="margin-small-left margin-small-right"
            :ids="selectedIds"
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
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width">
          <ListComponent
            v-model="selectedIds"
            :list="list"
            @on-sort="list = $event"
          />
        </div>
      </template>
    </FilterLayout>
    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
    />
  </div>
</template>

<script setup>
import FilterSettings from 'components/layout/Filter/FilterSettings.vue'
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import SelectAll from 'tasks/collection_objects/filter/components/selectAll.vue'
import AttributionComponent from './components/attributions/main.vue'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import { IMAGE } from 'constants/index.js'
import { Image } from 'routes/endpoints'
import { reactive, ref, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const selectedIds = ref([])

const preferences = reactive({
  activeFilter: true,
  activeJSONRequest: false,
  showList: true
})

const {
  isLoading,
  list,
  pagination,
  per,
  append,
  urlRequest,
  loadPage,
  parameters,
  makeFilterRequest,
  resetFilter
} = useFilter(Image)

onBeforeMount(() => {
  parameters.value = {
    ...URLParamsToJSON(location.href),
    ...JSON.parse(sessionStorage.getItem('filterQuery'))
  }

  sessionStorage.removeItem('filterQuery')

  if (Object.keys(parameters.value).length) {
    makeFilterRequest({ ...parameters.value })
  }
})
</script>

<script>
export default {
  name: 'FilterImages'
}
</script>
