<template>
  <div>
    <spinner-component
      v-if="isLoading"
      full-screen
      legend="Searching..."
      :logo-size="{ width: '100px', height: '100px'}"
    />
    <div class="flex-separate middle">
      <h1>Filter biological associations</h1>
      <menu-preferences v-model="preferences" />
    </div>

    <JsonRequestUrl
      v-show="preferences.activeJSONRequest"
      class="panel content separate-bottom"
      :url="urlRequest"
    />

    <div class="horizontal-left-content align-start">
      <filter-component
        class="separate-right"
        v-show="preferences.activeFilter"
        @parameters="makeFilterRequest({ ...$event, extend })"
        @reset="resetFilter"
      />
      <div class="full_width overflow-x-auto">
        <div
          v-if="list.length"
          class="horizontal-left-content flex-separate separate-bottom"
        >
          <csv-button
            :list="csvFields"
            :options="{ fields }"
          />
        </div>

        <div
          class="flex-separate margin-medium-bottom"
          v-if="pagination"
        >
          <pagination-component
            :pagination="pagination"
            @next-page="loadPage"
          />
          <pagination-count
            v-model="per"
            :pagination="pagination"
          />
        </div>

        <list-component
          v-if="list.length"
          v-model="selectedIds"
          :list="list"
        />
        <h2
          v-if="!list.length"
          class="subtle middle horizontal-center-content no-found-message"
        >
          No records found.
        </h2>
      </div>
    </div>
  </div>
</template>

<script setup>
import FilterComponent from './components/FilterView.vue'
import ListComponent from './components/ListResults.vue'
import CsvButton from 'components/csvButton'
import PaginationComponent from 'components/pagination'
import PaginationCount from 'components/pagination/PaginationCount'
import MenuPreferences from 'tasks/extracts/filter/components/MenuPreferences.vue'
import SpinnerComponent from 'components/spinner.vue'
import useFilter from 'tasks/extracts/filter/composables/useFilter.js'
import JsonRequestUrl from 'tasks/people/filter/components/JsonRequestUrl.vue'
import { BiologicalAssociation } from 'routes/endpoints'
import { computed, reactive, ref } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const extend = ['object', 'subject', 'biological_relationship', 'taxonomy', 'biological_relationship_types']

const csvFields = computed(() =>
  selectedIds.value.length
    ? list.value
    : []
)

const fields = [
  'id',
  {
    label: 'Order',
    value: 'subject.taxonomy.order'
  },
  {
    label: 'Family',
    value: 'subject.taxonomy.family'
  },
  {
    label: 'Genus',
    value: item => item.subject.taxonomy.genus.filter(Boolean).join(' ')
  },
  {
    label: 'Subject',
    value: 'subject.object_label'
  },
  {
    label: 'Biological properties',
    value: item => item.biological_relationship_types.filter(b => b.target === 'subject').map(b => b.biological_property.name).join(', ')
  },
  {
    label: 'Biological relationship',
    value: 'biological_relationship.object_label'
  },
  {
    label: 'Biological properties',
    value: item => item.biological_relationship_types.filter(b => b.target === 'object').map(b => b.biological_property.name).join(', ')
  },
  {
    label: 'Order',
    value: 'object.taxonomy.order'
  },
  {
    label: 'Family',
    value: 'object.taxonomy.family'
  },
  {
    label: 'Genus',
    value: item => item.object.taxonomy.genus.filter(Boolean).join(' ')
  },
  {
    label: 'Object',
    value: 'object.object_label'
  }
]

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
} = useFilter(BiologicalAssociation)

const urlParams = URLParamsToJSON(location.href)

if (Object.keys(urlParams).length) {
  makeFilterRequest({ ...urlParams, extend })
}

</script>

<style scoped>
  .no-found-message {
    height: 70vh;
  }
</style>
