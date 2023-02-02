<template>
  <div>
    <h1>Filter descriptors</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      :object-type="DESCRIPTOR"
      :selected-ids="selectedIds"
      :list="list"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <div
          v-if="list.length"
          class="horizontal-right-content"
        >
          <div class="horizontal-left-content">
            <TagAll
              :ids="selectedIds"
              :type="DESCRIPTOR"
            />
            <span class="separate-left separate-right">|</span>
            <CsvButton :list="csvList" />
          </div>
        </div>
      </template>
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #table>
        <div class="full_width overflow-x-auto">
          <FilterList
            v-model="selectedIds"
            :list="list"
            :attributes="ATTRIBUTES"
            @on-sort="list = $event"
          />
        </div>
      </template>
    </FilterLayout>
    <VSpinner
      v-if="isLoading"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px' }"
    />
  </div>
</template>

<script setup>
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import FilterView from './components/FilterView.vue'
import FilterList from 'components/layout/Filter/FilterList.vue'
import CsvButton from 'components/csvButton'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import { listParser } from './utils/listParser'
import { ATTRIBUTES } from './constants/attributes'
import { Descriptor } from 'routes/endpoints'
import { DESCRIPTOR } from 'constants/index.js'
import { computed, ref } from 'vue'

const selectedIds = ref([])

const {
  isLoading,
  list,
  pagination,
  append,
  urlRequest,
  loadPage,
  parameters,
  makeFilterRequest,
  resetFilter
} = useFilter(Descriptor, { listParser })

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)
</script>

<script>
export default {
  name: 'FilterDescriptors'
}
</script>
