<template>
  <div class="margin-medium-top">
    <FilterLayout
      :pagination="pagination"
      :url-request="urlRequest"
      :object-type="NAMESPACE"
      :selected-ids="sortedSelectedIds"
      :list="list"
      :radial-navigator="false"
      v-model="parameters"
      v-model:append="append"
      @filter="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @per="makeFilterRequest({ ...parameters, extend, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterView v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          :list="list"
          :attributes="ATTRIBUTES"
          :hide-unfrozen="hideFrozen"
          :preference-key="`tasks::filters::${NAMESPACE}`"
          v-model="selectedIds"
          @on-sort="(items) => (list = items)"
          @remove="({ index }) => list.splice(index, 1)"
        />
      </template>
      <template #nav-settings-start>
        <VToggle
          title="Hide/show non-frozen columns"
          @click="() => (hideFrozen = !hideFrozen)"
        >
          <VIcon
            title="Hide/show non-frozen columns"
            :name="hideFrozen ? 'contract' : 'expand'"
            x-small
          />
        </VToggle>
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
import FilterLayout from '@/components/layout/Filter/FilterLayout.vue'
import FilterView from './components/FilterView.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { ATTRIBUTES } from './constants/attributes'
import { listParser } from './utils/listParser'
import { NAMESPACE } from '@/constants/index.js'
import { Namespace } from '@/routes/endpoints'
import { ref } from 'vue'

const hideFrozen = ref(false)

const {
  append,
  isLoading,
  list,
  loadPage,
  makeFilterRequest,
  pagination,
  parameters,
  resetFilter,
  selectedIds,
  sortedSelectedIds,
  urlRequest
} = useFilter(Namespace, { listParser })
</script>

<script>
export default {
  name: 'FilterNamespace'
}
</script>
