<template>
  <div class="margin-medium-top">
    <FilterLayout
      v-model="parameters"
      :url-request="urlRequest"
      :list="downloadList"
      :csv-options="csvOptions"
      :radial-filter="false"
      :radial-linker="false"
      :radial-mass-annotator="false"
      :radial-navigator="false"
      :button-unify="false"
      :button-append="false"
      :button-nested-parameters="false"
      @filter="makeFilterRequest"
      @reset="resetFilter"
    >
      <template #nav-left>
        <span
          v-if="taxonName"
          class="middle"
        >
          Scoped: {{ taxonName.name }}
        </span>
      </template>
      <template #facets>
        <FilterView
          v-model="parameters"
          :taxon-name="taxonName"
          :rank-list="rankList"
          :supported-ranks="supportedRanks"
          @select-taxon-name="selectTaxonName"
        />
      </template>
      <template #table>
        <TableStats
          v-if="downloadList.length"
          :table-list="rankTable"
        />
        <h3
          v-else
          class="subtle middle horizontal-center-content"
        >
          No records found.
        </h3>
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
import { computed } from 'vue'
import FilterLayout from '@/components/layout/Filter/FilterLayout.vue'
import FilterView from './components/FilterView.vue'
import TableStats from './components/TableStats.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useRankTableFilter from './composables/useRankTableFilter.js'

defineOptions({
  name: 'TaxonNameStats'
})

const {
  isLoading,
  makeFilterRequest,
  parameters,
  rankList,
  rankTable,
  resetFilter,
  selectTaxonName,
  supportedRanks,
  taxonName,
  urlRequest
} = useRankTableFilter()

const downloadList = computed(() => {
  const { column_headers: headers = [], data = [] } = rankTable.value

  return data.map((row) =>
    Object.fromEntries(headers.map((header, index) => [header, row[index]]))
  )
})

const csvOptions = computed(() => ({
  fields: rankTable.value.column_headers || []
}))
</script>
