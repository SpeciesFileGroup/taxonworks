<template>
  <div>
    <h1>Filter people</h1>

    <FilterLayout
      :list="list"
      :url-request="urlRequest"
      :object-type="PEOPLE"
      :pagination="pagination"
      v-model="parameters"
      :selected-ids="selectedIds"
      v-model:append="append"
      @filter="makeFilterRequest()"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <span class="separate-left separate-right">|</span>
        <CsvButton
          class="margin-small-left"
          :list="csvList"
        />
      </template>
      <template #facets>
        <FilterComponent v-model="parameters" />
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
import FilterComponent from './components/FilterView.vue'
import FilterList from 'components/layout/Filter/FilterList.vue'
import CsvButton from 'components/csvButton'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import { ATTRIBUTES } from './constants/attributes.js'
import { PEOPLE } from 'constants/index.js'
import { People } from 'routes/endpoints'
import { computed, ref } from 'vue'

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)

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
} = useFilter(People)
</script>

<script>
export default {
  name: 'FilterPeople'
}
</script>
