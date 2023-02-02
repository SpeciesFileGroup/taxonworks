<template>
  <div>
    <h1>Filter sources</h1>

    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      v-model="parameters"
      :object-type="SOURCE"
      :selected-ids="selectedIds"
      :list="list"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #nav-right>
        <TagAll
          class="circle-button"
          :ids="selectedIds"
          :type="SOURCE"
        />
        <span class="separate-left separate-right">|</span>
        <div class="horizontal-left-content gap-small">
          <CsvButton :list="csvList" />
          <BibliographyButton
            :selected-list="selectedIds"
            :pagination="pagination"
            :params="parameters"
          />
          <BibtexButton
            :selected-list="selectedIds"
            :pagination="pagination"
            :params="parameters"
          />
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
      :logo-size="{ width: '100px', height: '100px' }"
    />
  </div>
</template>

<script setup>
import FilterLayout from 'components/layout/Filter/FilterLayout.vue'
import FilterComponent from './components/filter.vue'
import ListComponent from './components/list'
import CsvButton from 'components/csvButton'
import BibtexButton from './components/bibtex'
import BibliographyButton from './components/bibliography.vue'
import VSpinner from 'components/spinner.vue'
import useFilter from 'shared/Filter/composition/useFilter.js'
import TagAll from 'tasks/collection_objects/filter/components/tagAll.vue'
import { Source } from 'routes/endpoints'
import { SOURCE } from 'constants/index.js'
import { computed, ref } from 'vue'

const extend = ['documents']
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
} = useFilter(Source, { initParameters: { extend } })

const csvList = computed(() =>
  selectedIds.value.length
    ? list.value.filter((item) => selectedIds.value.includes(item.id))
    : list.value
)
</script>

<script>
export default {
  name: 'FilterSources'
}
</script>
