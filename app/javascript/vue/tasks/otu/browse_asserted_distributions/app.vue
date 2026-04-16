<template>
  <div id="vue-task-browse-asserted-distribution-object">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <div class="flex-separate middle">
      <h1>Browse asserted distributions</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeFilter"
            />
            Show filter
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="activeJSONRequest"
            />
            Show JSON Request
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="append"
            />
            Append results
          </label>
        </li>
      </ul>
    </div>
    <div
      v-show="activeJSONRequest"
      class="panel content separate-bottom"
    >
      <div class="flex-separate middle">
        <span> JSON Request: {{ urlRequest }} </span>
      </div>
    </div>

    <div class="horizontal-left-content align-start gap-medium">
      <VFilter
        class="filter"
        v-show="activeFilter"
        v-model="parameters"
        @reset="resetFilter"
        @select="
          (params) => makeFilterRequest({ ...params, per: 500, extend, embed })
        "
      />
      <div class="full_width">
        <VMap
          :lat="0"
          :lng="0"
          :zoom="1"
          width="100%"
          height="70vh"
          :geojson="geojson"
          resize
        />

        <TableList
          :list="list"
          :columns="COLUMNS"
          @sort="sortTable"
        >
          <template #citations="{ column }">
            <div class="flex-row gap-small middle">
              Citations
              <VBtn
                title="Sort alphabetically"
                color="primary"
                circle
                @click.stop="() => sortTable(column)"
              >
                <VIcon
                  name="alphabeticalSort"
                  title="Sort alphabetically"
                  x-small
                />
              </VBtn>
              <VBtn
                color="primary"
                circle
                title="Sort by year"
                @click.stop="() => sortTable('year')"
              >
                <VIcon
                  name="numberSort"
                  title="Sort by year"
                  x-small
                />
              </VBtn>
            </div>
          </template>
        </TableList>
      </div>
    </div>
  </div>
</template>

<script setup>
import VMap from '@/components/ui/VMap/VMap.vue'
import VFilter from './components/filter.vue'
import TableList from '@/tasks/otu/browse/components/assertedDistribution/TableList.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import listParser from './helpers/listParser'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { sortArray } from '@/helpers'
import { computed, ref } from 'vue'
import { useFilter } from '@/shared/Filter/composition'
import { AssertedDistribution } from '@/routes/endpoints'
import { usePolymorphicConverter } from '@/composables/usePolymorphismConverter'
import AssertedDistributionObject from '@/components/ui/SmartSelector/PolymorphicObjectPicker/PolymorphismClasses/AssertedDistributionObject'

const COLUMNS = [
  'level0',
  'level1',
  'level2',
  'name',
  'shape type',
  'presence',
  'shape',
  'citations',
  'object',
  'object type'
]

const extend = [
  'citations',
  'asserted_distribution_shape',
  'shape_type',
  'origin_citation',
  'source',
  'asserted_distribution_object'
]
const embed = ['level_names', 'shape']

defineOptions({ name: 'BrowseAssertedDistributions' })

usePolymorphicConverter(
  'asserted_distribution_object',
  AssertedDistributionObject
)

const {
  list,
  append,
  makeFilterRequest,
  urlRequest,
  resetFilter,
  isLoading,
  parameters
} = useFilter(AssertedDistribution, {
  initParameters: { extend, embed },
  listParser
})

const ascending = ref(false)
const activeFilter = ref(true)
const activeJSONRequest = ref(false)

const geojson = computed(() => list.value.map((item) => item.feature))

function sortTable(sortProperty) {
  list.value = sortArray(list.value, sortProperty, ascending.value, {
    stripHtml: true
  })

  ascending.value = !ascending.value
}
</script>

<style lang="scss">
#vue-task-browse-asserted-distribution-object {
  .header-box {
    height: 30px;
  }
  .filter {
    width: 400px;
    min-width: 400px;
  }
  :deep(.vue-autocomplete-input) {
    width: 100%;
  }
}
</style>
