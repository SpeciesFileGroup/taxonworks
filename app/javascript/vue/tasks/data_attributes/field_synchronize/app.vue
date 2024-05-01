<template>
  <div class="flex-separate middle">
    <h1>Field synchronize</h1>
    <a
      v-if="filterUrl"
      :href="filterUrl"
      >Back to filter</a
    >
  </div>
  <VSpinner
    v-if="isLoading"
    full-screen
  />
  <VSpinner
    v-if="isUpdating"
    full-screen
    legend="Saving..."
  />
  <div
    v-if="QUERY_PARAMETER[queryParam]"
    class="horizontal-left-content align-start gap-medium"
  >
    <NavBar
      navbar-class=""
      class="left-column"
    >
      <div class="flex-col gap-medium left-column">
        <FieldForm
          :predicates="predicates"
          :attributes="[...attributes, ...noEditableAttributes].sort()"
          v-model:selected-predicates="selectedPredicates"
          v-model:selected-attributes="selectedAttributes"
        />
        <RegexForm
          :to-exclude="noEditableAttributes"
          :attributes="selectedAttributes"
          :predicates="selectedPredicates"
          v-model="regexPatterns"
          v-model:to="to"
          v-model:from="from"
        />
      </div>
    </NavBar>
    <div class="overflow-x-scroll">
      <div class="horizontal-left-content middle gap-medium">
        <VPagination
          :pagination="pagination"
          @next-page="({ page }) => loadPage(page)"
        />
        <VPaginationCount
          :pagination="pagination"
          :max-records="PER_VALUES"
          v-model="per"
        />
      </div>
      <VTable
        :attributes="selectedAttributes"
        :list="tableList"
        :no-editable="noEditableAttributes"
        :predicates="selectedPredicates"
        :preview-header="previewHeader"
        :model="currentModel"
        :is-extract="!!extractOperation"
        @remove:attribute="removeSelectedAttribute"
        @remove:predicate="removeSelectedPredicate"
        @update:attribute="saveFieldAttribute"
        @update:attribute-column="saveColumnAttribute"
        @update:predicate-column="saveColumnPredicate"
        @update:data-attribute="saveDataAttribute"
        @update:preview="processPreview"
        @refresh="() => loadPage(1)"
        @sort:preview="sortListByMatched"
        @sort:property="sortListByEmpty"
      />
    </div>
  </div>
  <div v-else>
    <i v-if="queryParam">Query parameter is not supported</i>
    <i v-else>Query parameter is missing</i>
  </div>
</template>

<script setup>
import { QUERY_PARAMETER } from './constants'
import { useFieldSync } from './composables'

import VTable from './components/Table/VTable.vue'
import RegexForm from './components/Regex/RegexForm.vue'
import FieldForm from './components/Field/FieldForm.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VPaginationCount from '@/components/pagination/PaginationCount.vue'
import VPagination from '@/components/pagination.vue'
import NavBar from '@/components/layout/NavBar.vue'

defineOptions({
  name: 'FieldSynchronize'
})

const PER_VALUES = [50, 100, 200, 250]

const {
  attributes,
  currentModel,
  extractOperation,
  filterUrl,
  from,
  isLoading,
  isUpdating,
  loadPage,
  noEditableAttributes,
  pagination,
  per,
  predicates,
  previewHeader,
  processPreview,
  queryParam,
  regexPatterns,
  removeSelectedAttribute,
  removeSelectedPredicate,
  saveColumnAttribute,
  saveColumnPredicate,
  saveDataAttribute,
  saveFieldAttribute,
  selectedAttributes,
  selectedPredicates,
  sortListByEmpty,
  sortListByMatched,
  tableList,
  to
} = useFieldSync()
</script>

<style scoped>
.left-column {
  width: 440px;
}
</style>
