<template>
  <div class="margin-medium-top">
    <FilterLayout
      :url-request="urlRequest"
      :pagination="pagination"
      :object-type="CONTAINER"
      :selected-ids="sortedSelectedIds"
      :list="list"
      :radial-filter="false"
      :radial-linker="false"
      :radial-mass-annotator="false"
      :button-unify="false"
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
          v-model="selectedIds"
          :list="list"
          :attributes="ATTRIBUTES"
          :preference-key="`tasks::filters::${CONTAINER}`"
          @on-sort="list = $event"
          @remove="({ index }) => list.splice(index, 1)"
        >
          <template #contents="{ value }">
            <VBtn
              variant="outline"
              @click="() => (contentsContainerId = value)"
            >
              Show
            </VBtn>
          </template>
        </FilterList>
      </template>
    </FilterLayout>
    <ContentsModal
      v-if="contentsContainerId"
      :container-id="contentsContainerId"
      @close="() => (contentsContainerId = null)"
    />
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
import ContentsModal from './components/ContentsModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import useFilter from '@/shared/Filter/composition/useFilter.js'
import { ATTRIBUTES } from './constants/attributes'
import { CONTAINER } from '@/constants/index.js'
import { Container } from '@/routes/endpoints'
import { ref } from 'vue'

const extend = ['identifiers']

const contentsContainerId = ref(null)

function listParser(list) {
  return list.map((item) => ({
    ...item,
    identifiers: item.identifiers?.join('; '),
    contents: item.id,
    is_full: item.is_full ? 'Yes' : 'No'
  }))
}

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
} = useFilter(Container, {
  initParameters: { extend },
  listParser
})
</script>

<script>
export default {
  name: 'FilterContainers'
}
</script>
