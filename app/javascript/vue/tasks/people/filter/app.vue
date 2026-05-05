<template>
  <div class="margin-medium-top">
    <FilterLayout
      :list="list"
      :url-request="urlRequest"
      :object-type="PERSON"
      :pagination="pagination"
      :button-unify="false"
      :selected-ids="sortedSelectedIds"
      v-model:append="append"
      v-model="parameters"
      @filter="makeFilterRequest({ ...parameters, page: 1 })"
      @nextpage="loadPage"
      @reset="resetFilter"
    >
      <template #facets>
        <FilterComponent v-model="parameters" />
      </template>
      <template #table>
        <FilterList
          v-model="selectedIds"
          :list="list"
          :attributes="ATTRIBUTES"
          :hide-unfrozen="hideFrozen"
          :preference-key="`tasks::filters::${PERSON}`"
          @on-sort="list = $event"
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
import FilterComponent from './components/FilterView.vue'
import FilterList from '@/components/Filter/Table/TableResults.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VToggle from '@/components/ui/VToggle.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import { ATTRIBUTES } from './constants/attributes.js'
import { PERSON } from '@/constants/index.js'
import { People } from '@/routes/endpoints'
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
} = useFilter(People)
</script>

<script>
export default {
  name: 'FilterPeople'
}
</script>
